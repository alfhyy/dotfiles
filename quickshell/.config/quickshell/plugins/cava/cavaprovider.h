#pragma once

#include <QList>
#include <QMutex>
#include <QObject>
#include <QtQml/qqmlregistration.h>

#include <atomic>
#include <vector>

struct pw_thread_loop;
struct pw_stream;
struct cava_plan;

// Captures the default sink's monitor through PipeWire and runs libcava on it in-process.
// The cava plan (and its autosens calibration) outlives stream connects, so toggling
// `active` is instant and already calibrated.
class CavaProvider : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int bars READ bars WRITE setBars NOTIFY barsChanged)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(QList<qreal> values READ values NOTIFY valuesChanged)

public:
    explicit CavaProvider(QObject *parent = nullptr);
    ~CavaProvider() override;

    int bars() const { return m_bars; }
    void setBars(int bars);
    bool active() const { return m_active; }
    void setActive(bool active);
    QList<qreal> values() const { return m_values; }

    void process(); // PipeWire thread

signals:
    void barsChanged();
    void activeChanged();
    void valuesChanged();

private:
    void connectStream();
    void disconnectStream();
    void rebuildPlan();
    void publish();

    int m_bars = 28;
    bool m_active = false;
    QList<qreal> m_values;

    pw_thread_loop *m_loop = nullptr;
    pw_stream *m_stream = nullptr;
    cava_plan *m_plan = nullptr;

    std::vector<double> m_in;
    std::vector<double> m_out;
    bool m_settled = false;
    bool m_silent = true;

    QMutex m_mutex;
    QList<qreal> m_pending;
    std::atomic_bool m_queued = false;
};
