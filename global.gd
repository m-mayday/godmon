extends Node

signal player_party_changed
signal player_side_battlers_changed
signal foe_side_battlers_changed

const MAX_PLAY_TIME: float = (999 * 3600) + (59 * 60)

var player_name: String = "Red"
var player_party: Array[Pokemon] = []
var player_side_battlers: Array[Battler] = []
var foe_side_battlers: Array[Battler] = []
var play_time: float = 0.0

var _tracking_play_time: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS ## For tracking play time


func _process(delta: float) -> void:
	if _tracking_play_time:
		play_time += delta
		if play_time > MAX_PLAY_TIME:
			_tracking_play_time = false
			play_time = MAX_PLAY_TIME
			process_mode = Node.PROCESS_MODE_DISABLED


## Start tracking play time if MAX_PLAY_TIME hasn't been reached
func start_play_time_tracking() -> void:
	_tracking_play_time = play_time < MAX_PLAY_TIME


## Get current play time as string (HH:MM)
func get_total_play_time_string() -> String:
	return get_play_time_string(play_time)


## Get the provided time as string (HH:MM)
func get_play_time_string(time: float) -> String:
	var hours = int(time / 3600)
	var minutes = int(fmod(time, 3600) / 60)
	return "%02d:%02d" % [hours, minutes]


func set_player_party_value(index: int, value: Pokemon) -> void:
	if len(player_party) > index:
		player_party[index] = value
	else:
		player_party.append(value)
	player_party_changed.emit()


func get_player_battler(index: int) -> Battler:
	if len(player_side_battlers) > index:
		return player_side_battlers[index]
	return null
	

func get_foe_battler(index: int) -> Battler:
	if len(foe_side_battlers) > index:
		return foe_side_battlers[index]
	return null


func assign_player_battler_array(arr: Array[Battler]) -> void:
	player_side_battlers.assign(arr)
	player_side_battlers_changed.emit()


func assign_foe_battler_array(arr: Array[Battler]) -> void:
	foe_side_battlers.assign(arr)
	foe_side_battlers_changed.emit()


func update_player_party() -> void:
	player_party_changed.emit()


func update_player_battlers() -> void:
	player_side_battlers_changed.emit()


func increase_event_flag(flag: String) -> void:
	EVENT_FLAGS[flag] += 1


## Saves the game to the provided slot
func save_game(slot: int) -> bool:
	var main: Node2D = get_tree().root.get_node("Main")
	var current_scene_path: String = str(main.current_scene.get_path())
	var save_data: SaveData = SaveData.new()
	save_data.current_scene_file_path = main.current_scene.scene_file_path
	var nodes: Array[Node] = get_tree().get_nodes_in_group("persist")
	for node in nodes:
		var node_path: String = str(node.get_path())
		if current_scene_path in node_path:
			save_data.nodes[node_path] = {
				"position": node.position,
				"face_direction": node.face_direction,
			}
	save_data.player_name = player_name
	save_data.player_position = main.player.position - main.current_scene.position
	save_data.player_face_direction = main.player.face_direction
	save_data.play_time = play_time
	if OK != ResourceSaver.save(save_data, "user://sav/save{0}.res".format([slot])):
		return false
	return true


## Loads the save game corresponding to the provided slot
func load_game(slot: int) -> bool:
	var save_path: String = "user://sav/save{0}.res".format([slot])
	if not ResourceLoader.exists(save_path):
		return false
	var save_data = load(save_path)
	var main: Node2D = get_tree().root.get_node("Main")
	main.load_scene(save_data.current_scene_file_path)
	await SignalBus.scene_loaded
	main.player.position = save_data.player_position
	main.player.face_direction = save_data.player_face_direction
	main.player.turn(save_data.player_face_direction)
	play_time = save_data.play_time
	start_play_time_tracking()
	return true


## Gets all save files (limited to 3)
func get_save_files() -> Array[SaveData]:
	var save_files: Array[SaveData] = []
	for i in range(3):
		var path: String = "user://sav/save{0}.res".format([i])
		if ResourceLoader.exists(path):
			save_files.push_back(load(path))
	return save_files
	

var TRAINER_FLAGS: Dictionary[String, int] = {
	"route1_boy": 0,
}

var EVENT_FLAGS: Dictionary[String, int] = {
	"pallet_town_get_starter": 0,
}
