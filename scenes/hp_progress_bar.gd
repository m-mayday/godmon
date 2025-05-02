extends TextureProgressBar

## A percentage range and the color to use when health is in that range.
## The color is determined by checking that health percentage is greater than the range's minimum and less or equal than the maximum.
@export var percentage_color: Dictionary[Vector2, Color] = {
	Vector2(0.5, 1): Color("70f8a8"),
	Vector2(0.2, 0.5): Color("f8e038"),
	Vector2(0.0, 0.2): Color("f85838"),
}


func set_hp_bar_progress(new_health: int, max_health: int) -> void:
	max_value = max_health
	value = new_health
	var hp_percentage := float(new_health) / float(max_health)
	for percentage in percentage_color:
		if hp_percentage > percentage.x and hp_percentage <= percentage.y:
			tint_progress = percentage_color[percentage]
			break
