extends Node2D

## A dictionary of adjacent scene file paths and their position relative to this chunk
@export var adjacent_scenes: Dictionary[String, Vector2]

## The player spawn position in this chunk
@export var player_spawn_marker: Marker2D

## Returns the dictionary of adjacent scenes
func get_adjacent_scenes() -> Dictionary[String, Vector2]:
	return adjacent_scenes


## Returns the player spawn position in this chunk
func get_spawn_position() -> Vector2:
	return player_spawn_marker.position


## Emits the "zone_changed" signal if the Player (area) comes from a valid direction
func _on_area_2d_area_entered(area: Area2D, direction: Vector2) -> void:
	var face_direction: int = area.get_node("GridMovement")._face_direction
	if direction == Vector2.UP and face_direction == 0 \
		or direction == Vector2.DOWN and face_direction == 1 \
		or direction == Vector2.RIGHT and face_direction == 2 \
		or direction == Vector2.LEFT and face_direction == 3:
		SignalBus.zone_changed.emit(scene_file_path)
