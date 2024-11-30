shader_type canvas_item;

uniform vec4 shade1 : source_color;
uniform vec4 shade2 : source_color;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec4 round_to_shade(vec4 color) {
	if (color.a == 0.0) {
		return color;
	}
	if (color.r == 0.0) {
		return shade1;
	}
	return shade2;
}

void fragment() {
	COLOR = round_to_shade(COLOR);
}