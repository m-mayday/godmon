extends Node2D

func get_adjacent_scenes() -> Dictionary[String, Vector2]:
	return {
		"res://scenes/maps/town/town.tscn": Vector2(0, 40 * Constants.TILE_SIZE)
	}
