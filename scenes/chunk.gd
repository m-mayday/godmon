extends Node2D

## A dictionary of adjacent scene file paths and their position relative to this chunk
@export var adjacent_scenes: Dictionary[String, Vector2]

## The player spawn position in this chunk
@export var player_spawn_marker: Marker2D
@export var player_spawns: Dictionary[String, Node2D]
var current_spawn: Node2D


func _ready():
	SignalBus.scene_loaded.connect(_on_scene_loaded)


func with_data(data: Array) -> void:
	if len(data) > 0 and data[0] in player_spawns.keys():
		current_spawn = player_spawns[data[0]]
	else:
		current_spawn = player_spawn_marker


## Returns the dictionary of adjacent scenes
func get_adjacent_scenes() -> Dictionary[String, Vector2]:
	return adjacent_scenes


## Returns the player spawn position in this chunk
func get_spawn_position() -> Vector2:
	return current_spawn.position


## Emits the "zone_changed" signal if the Player (area) comes from a valid direction
func _on_area_2d_area_entered(area: Area2D, direction: Vector2) -> void:
	var face_direction: Vector2 = area.face_direction
	if direction == face_direction:
		SignalBus.zone_changed.emit(scene_file_path)


func _on_scene_loaded(previous_scene: String, new_scene: String) -> void:
	if new_scene == scene_file_path and previous_scene in player_spawns.keys():
		player_spawns[previous_scene].execute(true)
