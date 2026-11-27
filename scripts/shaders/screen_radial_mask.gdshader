shader_type canvas_item;
render_mode blend_mix;

// Screen Radial Mask Shader (Godot 4.7 Mobile Vulkan)
// Reshapes a flat full-rect ColorRect flash into a soft radial mask so screen-space
// feedback (biome transition flashes, Nitro boost kick) reads as atmospheric light or
// a vignette instead of a uniform screen-wide tint. Zero screen-texture reads: driven
// entirely by the rect's own color/alpha (already tweened by existing gameplay code),
// so no call sites elsewhere need to change — this only reshapes it spatially.
// Zero texture sampling: trivially cheap on mobile fill-rate.

uniform bool edge_weighted = true; // true: concentrate near screen edges (danger vignette).
                                    // false: concentrate near screen center (radiant glow burst).
uniform float falloff_softness : hint_range(0.1, 1.5) = 0.75;

void fragment() {
	vec2 centered = UV - vec2(0.5);
	// Correct for non-square aspect so the mask reads as a true circular/radial shape
	// regardless of the viewport's width-to-height ratio.
	float aspect = SCREEN_PIXEL_SIZE.y / max(SCREEN_PIXEL_SIZE.x, 0.00001);
	centered.x *= aspect;
	float dist = length(centered) * 2.0;

	float mask;
	if (edge_weighted) {
		mask = smoothstep(0.35, 0.35 + 1.1 * falloff_softness, dist);
	} else {
		mask = 1.0 - smoothstep(0.0, 1.1 * falloff_softness, dist);
	}

	COLOR.a = COLOR.a * clamp(mask, 0.0, 1.0);
}
