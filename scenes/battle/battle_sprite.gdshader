shader_type canvas_item;

uniform vec4 color: source_color = vec4(0.941, 0.596, 0.945, 1.0);
uniform float mix_amount: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, color.rgb, mix_amount);
}
