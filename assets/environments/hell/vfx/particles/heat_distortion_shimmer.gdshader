shader_type canvas_item;

// Godot 4.7 Heat Distortion Shimmer Shader
// Lightweight screen-reading refraction shader for volcanic lava heat haze

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise_texture : hint_default_white, repeat_enable;
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.008;
uniform vec2 scroll_velocity = vec2(0.02, -0.06);

void fragment() {
    vec2 noise_uv = UV + scroll_velocity * TIME;
    vec2 noise_offset = texture(noise_texture, noise_uv).rg * 2.0 - 1.0;
    
    // Taper distortion near top of bounding box
    float height_fade = smoothstep(0.0, 0.35, UV.y);
    vec2 distorted_screen_uv = SCREEN_UV + noise_offset * distortion_strength * height_fade;
    
    vec4 screen_color = texture(screen_texture, distorted_screen_uv);
    
    // Subtle warm thermal tinting
    vec4 heat_tint = vec4(1.05, 0.98, 0.92, 1.0);
    COLOR = screen_color * heat_tint;
}
