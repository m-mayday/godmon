class_name SaveData
extends Resource
## A class of data that conforms a save file

@export var current_scene_file_path: String
@export var player_name: String
@export var player_position: Vector2
@export var player_face_direction: Vector2
@export var nodes: Dictionary[String, Dictionary]
@export var trainer_flags: Dictionary[String, int]
@export var event_flags: Dictionary[String, int]
@export var play_time: float
