#include "cavaprovider.h"

#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>

#include <cava/cavacore.h>

#include <algorithm>

namespace {

constexpr unsigned kRate = 44100;
constexpr size_t kFrame = kRate / 60;

void onProcess(void *data) { static_cast<CavaProvider *>(data)->process(); }

const pw_stream_events kEvents = {
    .version = PW_VERSION_STREAM_EVENTS,
    .process = onProcess,
};

} // namespace

CavaProvider::CavaProvider(QObject *parent) : QObject(parent) {
    pw_init(nullptr, nullptr);
    m_loop = pw_thread_loop_new("qs-cava", nullptr);
    pw_thread_loop_start(m_loop);
    rebuildPlan();
    m_values = QList<qreal>(m_bars, 0);
}

CavaProvider::~CavaProvider() {
    disconnectStream();
    pw_thread_loop_stop(m_loop);
    pw_thread_loop_destroy(m_loop);
    if (m_plan) cava_destroy(m_plan);
}

void CavaProvider::setBars(int bars) {
    bars = std::clamp(bars, 1, 256);
    if (bars == m_bars) return;
    m_bars = bars;
    rebuildPlan();
    m_values = QList<qreal>(m_bars, 0);
    emit barsChanged();
    emit valuesChanged();
}

void CavaProvider::setActive(bool active) {
    if (active == m_active) return;
    m_active = active;
    if (active) {
        connectStream();
    } else {
        disconnectStream();
        m_values.fill(0);
        emit valuesChanged();
    }
    emit activeChanged();
}

void CavaProvider::rebuildPlan() {
    pw_thread_loop_lock(m_loop);
    if (m_plan) cava_destroy(m_plan);
    // same settings as scripts/cava.conf: autosens on, noise reduction .55, 50 Hz - 10 kHz.
    // cava_plan is opaque in this header, so params are kept in-range (bars clamped) instead of checking status
    m_plan = cava_init(m_bars, kRate, 1, 1, 0.55, 50, 10000);
    m_out.assign(m_bars, 0);
    m_settled = false;
    pw_thread_loop_unlock(m_loop);
}

void CavaProvider::connectStream() {
    pw_thread_loop_lock(m_loop);

    auto *props = pw_properties_new(
        PW_KEY_MEDIA_TYPE, "Audio",
        PW_KEY_MEDIA_CATEGORY, "Capture",
        PW_KEY_MEDIA_ROLE, "Music",
        PW_KEY_STREAM_CAPTURE_SINK, "true", // record what the default sink plays
        PW_KEY_NODE_PASSIVE, "true",        // never keep an idle sink awake
        PW_KEY_NODE_LATENCY, "512/44100",   // ~86 updates/s
        nullptr);
    m_stream = pw_stream_new_simple(pw_thread_loop_get_loop(m_loop), "quickshell-cava", props, &kEvents, this);

    uint8_t buffer[512];
    spa_pod_builder b;
    spa_pod_builder_init(&b, buffer, sizeof(buffer));
    spa_audio_info_raw info{};
    info.format = SPA_AUDIO_FORMAT_F32;
    info.rate = kRate;
    info.channels = 1;
    info.position[0] = SPA_AUDIO_CHANNEL_MONO;
    const spa_pod *params[] = { spa_format_audio_raw_build(&b, SPA_PARAM_EnumFormat, &info) };

    m_settled = false;
    m_in.clear();
    m_silent = true;
    pw_stream_connect(m_stream, PW_DIRECTION_INPUT, PW_ID_ANY,
                      static_cast<pw_stream_flags>(PW_STREAM_FLAG_AUTOCONNECT | PW_STREAM_FLAG_MAP_BUFFERS),
                      params, 1);

    pw_thread_loop_unlock(m_loop);
}

void CavaProvider::disconnectStream() {
    if (!m_stream) return;
    pw_thread_loop_lock(m_loop);
    pw_stream_destroy(m_stream);
    m_stream = nullptr;
    pw_thread_loop_unlock(m_loop);
}

void CavaProvider::process() {
    pw_buffer *pwb = pw_stream_dequeue_buffer(m_stream);
    if (!pwb) return;

    spa_data &d = pwb->buffer->datas[0];
    if (m_plan && d.data && d.chunk) {
        const auto *samples = static_cast<const float *>(SPA_PTROFF(d.data, d.chunk->offset, void));
        const uint32_t n = d.chunk->size / sizeof(float);

        for (uint32_t i = 0; i < n; i++) {
            m_in.push_back(samples[i] * 32767.0); // int16 range, as the cava CLI feeds it: autosens calibrates faster
            m_silent &= samples[i] == 0.f;
        }

        // run cava once per ~1/60 s of audio like the CLI: its smoothing is applied per call,
        // so feeding every small PipeWire chunk (~190 calls/s) over-smoothed the bars
        if (m_in.size() >= kFrame) {
            // once the bars have fallen to zero on silence, skip the FFT until sound returns
            if (!(m_silent && m_settled)) {
                cava_execute(m_in.data(), static_cast<int>(m_in.size()), m_out.data(), m_plan);
                m_settled = m_silent && std::all_of(m_out.begin(), m_out.end(), [](double v) { return v < 1e-3; });

                {
                    QMutexLocker lock(&m_mutex);
                    m_pending.assign(m_out.begin(), m_out.end());
                }
                // coalesce: at most one pending hop to the GUI thread
                if (!m_queued.exchange(true))
                    QMetaObject::invokeMethod(this, &CavaProvider::publish, Qt::QueuedConnection);
            }
            m_in.clear();
            m_silent = true;
        }
    }

    pw_stream_queue_buffer(m_stream, pwb);
}

void CavaProvider::publish() {
    m_queued = false;
    if (!m_active) return;
    {
        QMutexLocker lock(&m_mutex);
        m_values = m_pending;
    }
    emit valuesChanged();
}
