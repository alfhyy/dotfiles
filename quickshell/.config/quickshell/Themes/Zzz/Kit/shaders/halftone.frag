#version 440
// Halftone dots on a staggered grid, shrinking toward the bottom. Was a Canvas: repainting
// thousands of arcs in JS on every theme swap / new card; this is a few ALU ops per pixel.
// Build: /usr/lib/qt6/bin/qsb --qt6 -o halftone.frag.qsb halftone.frag

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 ink;    // premultiplied
    float pitch; // grid spacing px
    float rmax;  // dot radius at the top px
    vec2 px;     // item size px
};

void main() {
    vec2 p = qt_TexCoord0 * px;
    // rmax < pitch / 2, so the nearest centre in the nearest row is the only dot that can cover p
    float row = floor(p.y / pitch + 0.5);
    float off = mod(row, 2.0) * pitch * 0.5;
    vec2 c = vec2(floor((p.x - off) / pitch + 0.5) * pitch + off, row * pitch);
    float r = rmax * pow(max(0.0, 1.0 - c.y / px.y), 1.4);
    r *= step(0.25, r);
    fragColor = ink * clamp(r - length(p - c) + 0.5, 0.0, 1.0) * qt_Opacity;
}
