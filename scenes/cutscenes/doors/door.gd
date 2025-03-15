extends Cutscene
class_name Door

@export var _animator: AnimationPlayer
@export var target_scene_path: String ## Scene path to load
@export var current_scene_path: String ## Current scene (where the door is)
@export var is_exit_only: bool ## If it's an exit door only (like interior scenes)
@export var player_enter_direction: Vector2 = Vector2.UP ## The direction of the player to "enter" this door
@export var player_exit_direction: Vector2 = Vector2.DOWN ## The exit direction of the player to "exit" this door
@export var enter_tiles: int = 1 ## Amount of tiles to move the player when "entering" this door
@export var exit_tiles: int = 1 ## Amount of tiles to move the player when "exiting" this door


var _is_exiting: bool = false ## If player is currently exiting from this door.


## Animates the door opening/closing, moves the player and loads the target scene
func _execute() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if _is_exiting: # open door / move player / close door
		player.visible = false
		await get_tree().create_timer(0.5).timeout
		_animator.play("door_open")
		await _animator.animation_finished
		player.visible = true
		await player.cutscene_move(player.position + _get_target_position(player_exit_direction, exit_tiles), exit_tiles)
		_animator.play_backwards("door_open")
		await _animator.animation_finished
		return
	elif is_exit_only: # move player / load scene
		await player.cutscene_move(player.position + _get_target_position(player_exit_direction, exit_tiles), exit_tiles)
		player.visible = false
	else: # open door / move player / close door / load scene
		_animator.play("door_open")
		await _animator.animation_finished
		await player.cutscene_move(player.position + _get_target_position(player_enter_direction, enter_tiles), enter_tiles)
		player.visible = false
		_animator.play_backwards("door_open")
		await _animator.animation_finished
	get_tree().root.get_node("Main").load_scene(target_scene_path, true, false, [current_scene_path])


## Runs the cutscene
func execute(exiting: bool = false):
	_is_exiting = exiting
	run()


## Calculates the player's new position
func _get_target_position(direction: Vector2, tiles: int) -> Vector2:
	return Vector2(Constants.TILE_SIZE*tiles, Constants.TILE_SIZE*tiles)*direction
