shader_type canvas_item;
render_mode blend_mix;

// Celestial Atmospheric Glow Shader (Godot 4.7 Mobile Vulkan)
// Smooth feathered radial glow for golden celestial radiance, sun god-rays, and halos.
// Guarantees zero rectangular alpha edge cutoffs via smooth radial falloff.
// Zero screen-texture reads for optimal mobile performance on AMD Radeon 610M.

uniform vec4 glow_color : source_color = vec4(1.0, 0.92, 0.65, 0.85);
uniform float base_alpha : hint_range(0.0, 1.0) = 0.35;
uniform float pulse_speed : hint_range(0.0, 10.0) = 1.2;
uniform float pulse_intensity : hint_range(0.0, 0.5) = 0.08;
uniform float radial_sharpness : hint_range(0.5, 3.0) = 1.4;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Smooth radial distance from center
    float dist = length(UV - vec2(0.5, 0.5)) * 2.0;
    float radial_falloff = clamp(1.0 - pow(dist, radial_sharpness), 0.0, 1.0);
    radial_falloff = smoothstep(0.0, 1.0, radial_falloff);
    
    // 4-side border feathering to guarantee zero square box artifacts
    float edge_x = smoothstep(0.0, 0.15, UV.x) * smoothstep(1.0, 0.85, UV.x);
    float edge_y = smoothstep(0.0, 0.15, UV.y) * smoothstep(1.0, 0.85, UV.y);
    float edge_mask = edge_x * edge_y * radial_falloff;
    
    // Subtle breathing pulse
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_intensity;
    
    // Luminance modulation to keep core bright and periphery soft
    float core_lum = max(tex_color.r, max(tex_color.g, tex_color.b));
    
    COLOR.rgb = glow_color.rgb * pulse;
    COLOR.a = tex_color.a * glow_color.a * base_alpha * edge_mask * core_lum;
}
