extends Node2D

@export var world: Node
@export var animator: AnimationPlayer
@export var transition_layer: CanvasLayer
@export var transition_color: ColorRect
@export var player: Node2D


var current_scene: Node # The current scene loaded
var previous_scene: Node # The previous "current" scene when loading or changing a scene
var previous_world: Node # World that's been replaced when loading a new scene
var player_removed: bool = false # If the player has been removed from the scene tree
var _loaded_chunks: Dictionary[String, Node] = {}  # Dictionary of currently loaded map chunks
var thread: Thread # Thread to load adjacent scenes


func _ready() -> void:
	thread = Thread.new()
	load_scene("res://scenes/maps/town/town.tscn")
	SignalBus.zone_changed.connect(_change_scene)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"): # Speed up
		if Engine.time_scale == 5.0:
			Engine.time_scale = 1.0
		else:
			Engine.time_scale = 5.0


## Loads a new scene with the optional data provided if the scene has a "with_data" method
## The current scene can be freed (thus you can't return to it)
## The player can be removed from the SceneTree if needed (i.e. BattleScene)
func load_scene(scene_path: String, free_current: bool = false, remove_player:bool = false, data: Array = []) -> void:
	if scene_path in _loaded_chunks:
		_change_scene(scene_path)
		return
	
	# Fade out transition
	transition_layer.visible = true
	animator.play("fade_in")
	await animator.animation_finished

	if free_current and current_scene != null:
		current_scene.queue_free()
		_clear_chunks()
	elif current_scene != null:
		previous_world = world
		remove_child(world)
		previous_scene = current_scene

	current_scene = load(scene_path).instantiate()
	if current_scene.has_method("with_data"):
		current_scene.with_data(data)
		
	if remove_player:
		remove_child(player)
		player_removed = true
	else:
		if player_removed:
			add_child(player)
			player_removed = false

	if current_scene.has_method("get_adjacent_scenes"):
		_loaded_chunks[scene_path] = current_scene

	if get_node_or_null("World") == null:
		var new_world: Node2D = Node2D.new()
		new_world.name = "World"
		world = new_world
		add_child(world)
	
	world.add_child(current_scene)
	if not player_removed and current_scene.has_method("get_spawn_position"):
		player.position = current_scene.get_spawn_position()

	_update_adjacent_scenes(current_scene)
	
	animator.play_backwards("fade_in")
	await animator.animation_finished
	transition_color.color.a = 0
	transition_layer.visible = false


## Loads adjacent scenes given the current scene and adds them to _loaded_chunks
func _load_adjacent_scenes(new_scene: Variant) -> void:
	if not new_scene.has_method("get_adjacent_scenes"):
		return
		
	var adjacent_scenes: Dictionary[String, Vector2] = new_scene.get_adjacent_scenes()

	for scene in adjacent_scenes:
		if scene not in _loaded_chunks:
			var chunk: Variant = load(scene).instantiate()
			chunk.position = new_scene.position + adjacent_scenes[scene]
			world.call_deferred("add_child", chunk)
			_loaded_chunks[scene] = chunk


## If the previous scene wasn't freed, it loads it back in as it was
## along with any other loaded adjacent scenes
func return_to_previous_scenes() -> void:
	if previous_world != null:
		transition_layer.visible = true
		animator.play("fade_in")
		await animator.animation_finished
		current_scene.queue_free()
		current_scene = previous_scene
		remove_child(world)
		add_child(previous_world)
		world = previous_world
		previous_world = null
		if player_removed:
			add_child(player)
		animator.play("fade_in")
		await animator.animation_finished
		transition_color.color.a = 0
		transition_layer.visible = false


## Frees loaded chunks/adjacent scenes
func _clear_chunks() -> void:
	for chunk in _loaded_chunks.values():
		chunk.queue_free()
	_loaded_chunks.clear()


## Changes the current scene with a new adjacent one
## and it updates the adjacent scenes
func _change_scene(new_scene_path: String) -> void:
	if new_scene_path == current_scene.scene_file_path or new_scene_path not in _loaded_chunks.keys():
		return  # Already the current scene

	current_scene = _loaded_chunks[new_scene_path]
	_update_adjacent_scenes(current_scene)


## Frees scenes that are not adjacent to the new scene
## Calls _load_adjacent_scenes in a thread
func _update_adjacent_scenes(new_scene: Variant) -> void:
	if not new_scene.has_method("get_adjacent_scenes"):
		return
		
	var new_adjacent_scenes: Dictionary[String, Vector2] = new_scene.get_adjacent_scenes()

	# Unload scenes that are no longer adjacent
	for path in _loaded_chunks.keys():
		if path not in new_adjacent_scenes.keys() and path != new_scene.scene_file_path:
			var chunk: Node = _loaded_chunks[path]
			_loaded_chunks.erase(path)
			chunk.queue_free()
			
	if thread.is_started():
		thread.wait_to_finish()
	thread.start(_load_adjacent_scenes.bind(new_scene)) # Load adjacent scenes in thread
