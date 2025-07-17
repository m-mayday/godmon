extends Node2D

## A dictionary of adjacent scene file paths and their position relative to this chunk
@export var adjacent_scenes: Dictionary[String, Vector2]

## The player spawn position in this chunk
@export var player_spawn_marker: Marker2D
@export var player_spawns: Dictionary[String, Node2D]
@export var moving_objects: Array[Node2D] = [] ## The moving objects (i.e. NPCs) in this chunk
@export var save_location: String ## The location to display when saving the game. Not necessarily the same as this chunk's name
var current_spawn: Node2D


func with_data(data: Dictionary) -> void:
	if data.has("current_scene") and data["current_scene"] in player_spawns.keys():
		current_spawn = player_spawns[data["current_scene"]]
	else:
		current_spawn = player_spawn_marker


## Returns the dictionary of adjacent scenes
func get_adjacent_scenes() -> Dictionary[String, Vector2]:
	return adjacent_scenes


## Returns the player spawn position in this chunk
func get_spawn_position() -> Vector2:
	if current_spawn == null:
		return Vector2.ZERO
	return current_spawn.position


## Emits the "zone_changed" signal if the Player (area) comes from a valid direction
func _on_area_2d_area_entered(area: Area2D, direction: Vector2) -> void:
	var face_direction: Vector2 = area.face_direction
	if direction == face_direction:
		SignalBus.zone_changed.emit(scene_file_path)
