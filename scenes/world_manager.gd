extends Node2D

@export var world: Node2D ## The World node to which all maps are added.

var current_map: Node: ## The current map the player is in.
		set(value):
			current_map = value
var previous_map: Node ## The previous map when loading or changing to a new one.
var previous_world: Node ## A reference to a previous World that's been replaced when loading a new map

var _thread: Thread # Thread to load adjacent maps
var _loaded_maps: Dictionary[String, Node] = {}  # Dictionary of currently loaded maps

func _ready() -> void:
	_thread = Thread.new()


## Loads a new map with the optional data provided if the map has a "with_data" method
func load_map(map_path: String, player: Node = null, free_current: bool = false, data: Dictionary = {}) -> void:
	if map_path in _loaded_maps:
		_change_map(map_path)
		return

	var previous_map_path: String = get_current_map_path()
	
	if free_current:
		unload_current_map()
	else:
		save_world()
	
	current_map = load(map_path).instantiate()
	if current_map.has_method("with_data"):
		current_map.with_data(data)
		
	if get_node_or_null("World") == null:
		var new_world: Node2D = Node2D.new()
		new_world.name = "World"
		world = new_world
		add_child(world)

	world.add_child(current_map)

	if current_map.has_method("get_adjacent_maps"):
		_loaded_maps[map_path] = current_map
	
	if player != null and player.is_inside_tree():
		player.position = get_map_player_spawn_position()

	_update_adjacent_maps(current_map)
	SignalBus.scene_loaded.emit(previous_map_path, map_path)


## Returns if the map has already been loaded and is currently in the scene tree.
func is_map_in_tree(map_path: String) -> bool:
	return map_path in _loaded_maps


## Returns the current map
func get_current_map() -> Node:
	return current_map


## Returns the current map path
func get_current_map_path() -> String:
	if current_map != null:
		return current_map.scene_file_path
	return ""


## Returns the current maps's spawn position for the player
func get_map_player_spawn_position() -> Vector2:
	if current_map != null and current_map.has_method("get_spawn_position"):
		return current_map.get_spawn_position()
	return Vector2.ZERO


## Frees the current scene and clears all loaded chunks
func unload_current_map() -> void:
	if current_map != null:
		current_map.queue_free()
		_clear_loaded_maps()
	current_map = null


## Keeps a reference to the scenes loaded currently, to be restored later
func save_world() -> void:
	if current_map != null:
		previous_world = world
		remove_child(world)
		previous_map = current_map


## Restores the previously saved scenes, if they are not null
func restore_world() -> void:
	if previous_world == null:
		return
	if current_map != null:
		current_map.queue_free()
	current_map = previous_map
	remove_child(world)
	add_child(previous_world)
	world = previous_world
	previous_world = null


## Returns if a previous world has been saved or not
func has_previous_world() -> bool:
	return previous_world != null


## Changes the current scene to one of the already loaded chunks and updates them
func _change_map(new_map_path: String) -> void:
	if new_map_path == current_map.scene_file_path:
		return
	if new_map_path not in _loaded_maps.keys():
		return

	current_map = _loaded_maps[new_map_path]
	_update_adjacent_maps(current_map)
	
	
## Clears the loaded chunks
func _clear_loaded_maps() -> void:
	for map in _loaded_maps.values():
		map.queue_free()
	_loaded_maps.clear()


## Frees scenes that are not adjacent to the new scene, and loads the adjacent ones.
func _update_adjacent_maps(new_map: Node) -> void:
	if not new_map.has_method("get_adjacent_maps"):
		return

	var new_adjacent_maps: Dictionary[String, Vector2] = new_map.get_adjacent_maps()

	# Unload scenes not adjacent anymore
	for path in _loaded_maps.keys():
		if path not in new_adjacent_maps.keys() and path != new_map.scene_file_path:
			var chunk: Node = _loaded_maps[path]
			_loaded_maps.erase(path)
			chunk.queue_free()

	# Load new adjacent in background thread
	if _thread.is_started():
		_thread.wait_to_finish()
	_thread.start(_load_adjacent_maps.bind(new_map))


## Collects the new adjacent maps to be loaded.
func _load_adjacent_maps(new_map: Node) -> void:
	var adjacent_maps: Dictionary[String, Vector2] = new_map.get_adjacent_maps()
	var new_maps: Dictionary[String, Node] = {}
	for scene_path in adjacent_maps:
		if scene_path not in _loaded_maps:
			var map = load(scene_path).instantiate()
			map.position = new_map.position + adjacent_maps[scene_path]
			new_maps[scene_path] = map
	call_deferred("_add_loaded_maps", new_maps)


## Adds the new maps to the tree.
func _add_loaded_maps(new_maps: Dictionary) -> void:
	for path in new_maps.keys():
		world.add_child(new_maps[path])
		_loaded_maps[path] = new_maps[path]
