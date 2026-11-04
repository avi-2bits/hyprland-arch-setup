#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

/* =========================================================================
   WARM PASTEL + UNIFORM FULL-SCREEN GRAIN TUNING
   ========================================================================= */

// Color saturation: 0.44 produces deep, elegant matte pastel tones
const float SATURATION      = 0.44;

// Warmth multiplier: boosted to 1.15 for rich golden-hour paper tone
const float WARMTH          = 1.15;

// Uniform screen-wide grain strength: 0.082 provides consistent tactile texture
const float GRAIN_INTENSITY = 0.082;

// Grain scale: 620.0 preserves the preferred fine grain sizing
const float GRAIN_SCALE     = 620.0;

// Charcoal black lift: prevents texture from clipping into pure black
const float BLACK_LIFT      = 0.040;

// Contrast: relaxes digital harshness
const float CONTRAST        = 0.92;

// Brightness compensation
const float BRIGHTNESS      = 0.97;


/* =========================================================================
   FAST STATIC HASH GENERATOR
   ========================================================================= */
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    vec4 src = texture(tex, v_texcoord);
    vec3 color = src.rgb;

    // 1. Perceptual Luminance
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));

    // 2. Deep Pastel Desaturation
    color = mix(vec3(luma), color, SATURATION);

    // 3. Rich Amber-Gold Paper Warmth
    // Applies warm amber/ivory cast across the entire color spectrum
    const vec3 paperWarmth = vec3(1.14, 1.00, 0.72);
    color = mix(color, color * paperWarmth, WARMTH);

    // 4. Black Floor Lift (Keeps grain visible across solid pitch-black areas)
    color += vec3(BLACK_LIFT);

    // 5. Contrast & Brightness Softening
    color = (color - 0.5) * CONTRAST + 0.5;
    color *= BRIGHTNESS;

    // 6. Uniform Full-Screen Grain (Fast, unmasked single-cycle addition)
    float grain = (hash(v_texcoord * GRAIN_SCALE) - 0.5) * GRAIN_INTENSITY;
    color += grain;

    fragColor = vec4(clamp(color, 0.0, 1.0), src.a);
}

