#version 300 es
precision highp float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec2 center = uv - 0.5;

    // Screen curvature
    uv += center * dot(center, center) * 0.20;

    // Sample screen
    vec4 c = texture(tex, uv);

    // Scanlines
    float y = uv.y * float(textureSize(tex, 0).y);
    float scanline = 0.65 + 0.35 * cos(y * 3.14159);

    // RGB phosphor grille
    float x = mod(floor(uv.x * float(textureSize(tex, 0).x)), 3.0);
    vec3 grille = vec3(
        x < 1.0 ? 1.0 : 0.82,
        x < 1.0 ? 0.82 : (x < 2.0 ? 1.0 : 0.82),
        x > 1.0 ? 1.0 : 0.82
    );

    // Slight edge darkening
    vec2 edge = center * 2.0;
    float vignette = 1.0 - dot(edge, edge) * 0.13;

    vec3 color = c.rgb * scanline * grille * vignette;

    fragColor = vec4(color, c.a);
}
