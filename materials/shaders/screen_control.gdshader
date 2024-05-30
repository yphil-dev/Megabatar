shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb * vec3(SCREEN_UV.x, SCREEN_UV.y, 1.0 - SCREEN_UV.x), 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
