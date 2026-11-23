shader_type canvas_item;

// Cloud Soft Blend Shader (Godot 4.7 Mobile Vulkan)
// Lightweight UV translation and edge softening for celestial cloud banks.
// Highly optimized for mobile: no texture sampling loops.

uniform vec2 drift_velocity = vec2(0.015, 0.0);
uniform float edge_softness : hint_range(0.0, 0.5) = 0.15;
uniform vec4 cloud_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float opacity_multiplier : hint_range(0.0, 1.0) = 0.9;

void fragment() {
    vec2 moving_uv = UV + drift_velocity * TIME;
    vec4 tex_color = texture(TEXTURE, moving_uv);
    
    // Soft horizontal boundary feathering
    float edge_h = smoothstep(0.0, edge_softness, UV.x) * smoothstep(1.0, 1.0 - edge_softness, UV.x);
    float edge_v = smoothstep(0.0, edge_softness, UV.y) * smoothstep(1.0, 1.0 - edge_softness, UV.y);
    float edge_mask = edge_h * edge_v;
    
    COLOR.rgb = tex_color.rgb * cloud_tint.rgb;
    COLOR.a = tex_color.a * opacity_multiplier * edge_mask;
}
