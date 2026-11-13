shader_type canvas_item;
render_mode blend_add;

// Celestial Atmospheric Glow Shader (Godot 4.7 Mobile Vulkan)
// Lightweight additive shader for golden palace god-rays, cathedral window beams, and ethereal halos.
// Zero screen-texture reads for optimal mobile performance on AMD Radeon 610M.

uniform vec4 glow_color : source_color = vec4(1.0, 0.92, 0.65, 1.0);
uniform float base_alpha : hint_range(0.0, 1.0) = 0.45;
uniform float pulse_speed : hint_range(0.0, 10.0) = 1.8;
uniform float pulse_intensity : hint_range(0.0, 0.5) = 0.12;
uniform float vertical_falloff : hint_range(0.0, 2.0) = 0.8;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Subtle sinusoidal breathing pulse
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_intensity;
    
    // Smooth vertical feathering
    float falloff = pow(1.0 - UV.y, vertical_falloff);
    
    // Final additive color composition
    COLOR.rgb = tex_color.rgb * glow_color.rgb * pulse;
    COLOR.a = tex_color.a * base_alpha * falloff;
}
