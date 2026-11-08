#version 440
// Android-style progress: travelling sine wave up to the playhead, flat track after, pill thumb.
// Build: /usr/lib/qt6/bin/qsb --qt6 -o squiggle.frag.qsb squiggle.frag

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;  // 0..1
    float phase;     // radians, advances while playing
    float amp;       // wave amplitude in px (eases to 0 when paused)
    vec2 px;         // item size in px
    vec4 playedColor; // played part + thumb
    vec4 trackColor;  // unplayed part
};

const float TAU = 6.2831853;
const float LAMBDA = 22.0; // wavelength px
const float THICK = 2.6;   // line thickness px
const float PAD = 6.0;     // keeps the thumb/caps inside the item

float coverage(float d, float halfw) { return clamp(halfw - d + 0.5, 0.0, 1.0); }

void main() {
    vec2 p = qt_TexCoord0 * px;
    float y0 = px.y * 0.5;
    float x0 = PAD, x1 = px.x - PAD;
    float head = mix(x0, x1, progress);

    // played: sine distance, divided by the slope so thickness stays even along the curve
    float k = TAU / LAMBDA;
    float s = k * p.x - phase;
    float wy = y0 + amp * sin(s);
    float slope = amp * k * cos(s);
    float dWave = abs(p.y - wy) / sqrt(1.0 + slope * slope);
    // round start cap + clip at the playhead
    float played = coverage(dWave, THICK * 0.5) * step(x0, p.x) * clamp(head - p.x + 0.5, 0.0, 1.0);
    played = max(played, coverage(length(p - vec2(x0, y0 + amp * sin(k * x0 - phase))), THICK * 0.5));

    // unplayed: flat, thinner, starting a little after the thumb
    float gap = 5.0;
    float rest = coverage(abs(p.y - y0), THICK * 0.4) * clamp(p.x - (head + gap) + 0.5, 0.0, 1.0)
               * clamp(x1 - p.x + 0.5, 0.0, 1.0);

    // thumb: vertical pill 4 x 16 at the playhead
    vec2 q = abs(p - vec2(head, y0)) - vec2(2.0 - 2.0, 8.0 - 2.0);
    float dThumb = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - 2.0;
    float thumb = clamp(0.5 - dThumb, 0.0, 1.0);

    vec4 c = trackColor * rest;
    c = mix(c, playedColor, max(played, thumb));
    fragColor = c * qt_Opacity;
}
