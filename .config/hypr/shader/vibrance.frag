//
// Vibrance Boost Shader (GLSL ES 3.00 compatible)
// Tested with Hyprland screen_shader
//

#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

// Strength of the effect. Range: [-2.0, 2.0]
//  0.0 = no change
//  > 0.0 = boost vibrance
//  < 0.0 = reduce vibrance
uniform float strength = 0.8;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    vec3 color = pixColor.rgb;

    // Compute perceived brightness (Rec.709)
    const vec3 lumaCoeff = vec3(0.2126, 0.7152, 0.0722);
    float luma = dot(color, lumaCoeff);

    // Compute saturation (range 0–1)
    float maxC = max(max(color.r, color.g), color.b);
    float minC = min(min(color.r, color.g), color.b);
    float sat = maxC - minC;

    // Vibrance scaling factor (stronger for desaturated pixels)
    float factor = 1.0 + strength * (1.3 - sat * 1.3);
    factor = clamp(factor, 0.0, 3.0);

    // Apply vibrance change
    vec3 adjusted = mix(vec3(luma), color, factor);

    fragColor = vec4(adjusted, pixColor.a);
}
