#version 440
// Theme transition: the old-theme snapshot drains away behind a wobbly liquid front pouring down.
// Build: /usr/lib/qt6/bin/qsb --qt6 -o liquid.frag.qsb liquid.frag

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress; // 0 = all old, 1 = all new
    float seed;     // varies the wave shape per transition
    vec2 px;        // item size in pixels
};

layout(binding = 1) uniform sampler2D old;

void main() {
    vec2 p = qt_TexCoord0 * px;
    float amp = 14.0;

    // front travels from above the top to below the bottom, so both ends are fully covered
    float front = mix(-3.0 * amp, px.y + 3.0 * amp, progress);
    float wave = amp * (sin(p.x / 17.0 + seed + progress * 7.0) * 0.6
                      + sin(p.x / 6.5 - seed * 1.7 - progress * 11.0) * 0.25);
    // a few drips running ahead of the front
    float drip = 2.2 * amp * pow(max(0.0, sin(p.x / 9.0 + seed * 3.1)), 12.0);
    float edge = front + wave + drip;

    // old remains below the front; ~2px antialiased edge
    float keep = smoothstep(-1.2, 1.2, p.y - edge);
    // thin glossy meniscus riding the front
    float sheen = (1.0 - smoothstep(0.0, 3.0, abs(p.y - edge))) * 0.35 * (1.0 - progress);

    vec4 o = texture(old, qt_TexCoord0) * keep;
    fragColor = (o + vec4(sheen) * o.a) * qt_Opacity;
}
