class_name SaveData
extends Resource
## A class of data that conforms a save file

@export var current_scene_file_path: String
@export var save_location: String
@export var player_name: String
@export var player_gender: Constants.GENDER
@export var player_party: Array[Pokemon]
@export var player_position: Vector2
@export var player_face_direction: Vector2
@export var rival_name: String
@export var nodes: Dictionary[String, Dictionary]
@export var trainer_flags: Dictionary[String, int]
@export var event_flags: Dictionary[String, int]
@export var play_time: float


func save_game(slot: int, tree: SceneTree) -> bool:
	var main: Node2D = tree.root.get_node("Main")
	var current_scene_path: String = str(main.current_scene.get_path())
	current_scene_file_path = main.current_scene.scene_file_path
	var save_nodes: Array[Node] = tree.get_nodes_in_group("persist")
	for node in save_nodes:
		var node_path: String = str(node.get_path())
		if current_scene_path in node_path:
			nodes[node_path] = {
				"position": node.position,
				"face_direction": node.face_direction,
			}
	player_position = main.player.position - main.current_scene.position
	player_face_direction = main.player.face_direction
	save_location = main.current_scene.save_location
	if OK != ResourceSaver.save(self, "user://sav/save{0}.res".format([slot])):
		return false
	return true


## Loads the save game corresponding to the provided slot
func load_game(slot: int, tree: SceneTree) -> bool:
	var save_path: String = "user://sav/save{0}.res".format([slot])
	if not ResourceLoader.exists(save_path):
		return false
	var save_data: SaveData = load(save_path)
	player_name = save_data.player_name
	rival_name = save_data.rival_name
	play_time = save_data.play_time
	player_party.assign(save_data.player_party)
	player_gender = save_data.player_gender
	var main: Node2D = tree.root.get_node("Main")
	main.call_deferred("load_scene", save_data.current_scene_file_path)
	await SignalBus.scene_loaded
	if player_gender == Constants.GENDER.FEMALE:
		main.player.set_texture(load("res://assets/characters/player_female.png"))
	main.player.position = save_data.player_position
	main.player.face_direction = save_data.player_face_direction
	main.player.turn(save_data.player_face_direction)
	Global.start_play_time_tracking()
	return true
