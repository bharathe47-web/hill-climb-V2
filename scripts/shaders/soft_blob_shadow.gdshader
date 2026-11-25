shader_type canvas_item;
render_mode blend_mix;

// Soft Blob Shadow Shader (Godot 4.7 Mobile Vulkan)
// A simple soft-edged shadow blob for ground-contact shadows under vehicles/characters.
// Zero texture sampling: the host Sprite2D's own non-uniform scale defines the ellipse
// shape (a wide, short scale reads as a flat ground shadow), this shader just adds the
// soft radial falloff on top of that in local UV space.

uniform float inner_radius : hint_range(0.0, 1.0) = 0.3;
uniform float outer_radius : hint_range(0.0, 1.5) = 1.0;

void fragment() {
	vec2 centered = (UV - vec2(0.5)) * 2.0;
	float dist = length(centered);
	float mask = 1.0 - smoothstep(inner_radius, outer_radius, dist);
	COLOR.a = COLOR.a * clamp(mask, 0.0, 1.0);
}
