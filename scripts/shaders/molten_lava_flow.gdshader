shader_type canvas_item;

// Molten Lava Flow Shader (Godot 4.7 Mobile Vulkan)
// High-efficiency animated magma surface with dual-harmonic UV displacement and thermal glow pulse.
// Zero screen-reading costs; perfectly suited for mobile fill-rates on AMD Radeon 610M.

uniform vec2 flow_velocity = vec2(0.08, 0.0);
uniform float wave_amplitude : hint_range(0.0, 0.05) = 0.015;
uniform float wave_frequency : hint_range(1.0, 25.0) = 8.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.5;

uniform vec4 magma_glow_tint : source_color = vec4(1.05, 0.45, 0.05, 1.0);
uniform float thermal_pulse_speed : hint_range(0.0, 10.0) = 1.6;
uniform float thermal_pulse_amount : hint_range(0.0, 0.4) = 0.12;

void fragment() {
    // Harmonic wave offset on UV coordinates
    float wave_x = sin(UV.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float wave_y = cos(UV.x * wave_frequency * 0.75 + TIME * (wave_speed * 0.8)) * (wave_amplitude * 0.6);
    vec2 displaced_uv = UV + vec2(wave_x, wave_y) + flow_velocity * TIME;
    
    vec4 tex_color = texture(TEXTURE, displaced_uv);
    
    // Thermal heat pulsing
    float heat_factor = 1.0 + sin(TIME * thermal_pulse_speed + UV.x * 4.0) * thermal_pulse_amount;
    
    COLOR.rgb = tex_color.rgb * magma_glow_tint.rgb * heat_factor;
    COLOR.a = tex_color.a;
}
