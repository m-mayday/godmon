extends Node2D

@export var world: Node
@export var animator: AnimationPlayer
@export var transition_layer: CanvasLayer
@export var transition_color: ColorRect
@export var player: Node2D
@export var intro_scene: PackedScene
@export var main_menu: PackedScene
@export var world_manager: Node
@export var transition_manager: TransitionManager

var player_removed: bool = false # If the player has been removed from the scene tree

func _ready() -> void:
	Global.transition_manager = transition_manager
	SignalBus.input_paused.emit(true)
	if len(Global.get_save_files()) <= 0:
		play_intro()
	else:
		var menu = main_menu.instantiate()
		var transition_finished: Signal = transition_manager.fade_out()
		add_child(menu)
		await transition_finished
		SignalBus.input_paused.emit(true)
	SignalBus.zone_changed.connect(world_manager.load_map)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"): # Speed up
		if Engine.time_scale == 3.0:
			Engine.time_scale = 1.0
		else:
			Engine.time_scale = 3.0


## Loads a new scene with the optional data provided if the scene has a "with_data" method
## The current scene can be freed (thus you can't return to it)
## The player can be removed from the SceneTree if needed (i.e. BattleScene)
func load_scene(scene_path: String, free_current: bool = false, remove_player:bool = false, data: Dictionary = {}) -> void:
	if world_manager.is_map_in_tree(scene_path):
		world_manager.load_map(scene_path, player, free_current, data)
		return
	
	Cutscene._is_cutscene_in_progress = true # Loading a scene is a special case that we'd like to treat as a cutscene
	var previous_scene_path: String = world_manager.get_current_map_path()
	
	
	if world_manager.get_current_map() != null:
		await transition_manager.fade_in()

	if remove_player:
		remove_child(player)
		player_removed = true
	else:
		if player_removed:
			add_child(player)
			player_removed = false

	world_manager.call_deferred("load_map", scene_path, player, free_current, data)

	await SignalBus.scene_loaded
	await transition_manager.fade_out()
	Cutscene._is_cutscene_in_progress = false
	SignalBus.scene_transition_finished.emit(previous_scene_path, scene_path)


## If the previous scene wasn't freed, it loads it back in as it was
## along with any other loaded adjacent scenes
func return_to_previous_scenes() -> void:
	if world_manager.has_previous_world():
		await transition_manager.fade_in()
		world_manager.restore_world()
		
		if player_removed:
			add_child(player)

		await transition_manager.fade_out()
		SignalBus.input_paused.emit(false)


## Checks if there is or was an object at the specified coordinates
func will_collide_with_moving_object(coords: Vector2) -> bool:
	var current_scene: Node = world_manager.get_current_map()
	if current_scene == null:
		return false
	for object in current_scene.moving_objects:
		if current_scene.to_global(object.next_position) == coords or current_scene.to_global(object.previous_position) == coords:
			return true
	return false


## Checks if the player is or was at the specified coordinates
func will_collide_with_player(coords: Vector2) -> bool:
	if player.next_position == coords or player.previous_position == coords:
		return true
	return false


## Play the game's intro
func play_intro() -> void:
	var intro = intro_scene.instantiate()
	var transition_finished: Signal = transition_manager.fade_out()
	add_child(intro)
	await transition_finished
	SignalBus.input_paused.emit(true)
	await intro.intro_finished
	if Global.game_data.player_gender == Constants.GENDER.FEMALE:
		player.set_texture(load("res://assets/characters/player_female.png"))
	player.turn(Vector2.UP)
	intro.queue_free()
	Global.start_play_time_tracking()
	load_scene("res://scenes/maps/town/redshouse.tscn")
