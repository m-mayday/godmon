extends Sprite2D

signal movement_started(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)
signal movement_finished(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)


const ANIMATION_PARAMETERS: Dictionary[String, String] = {
	"idle": "parameters/idle/blend_position",
	"walk": "parameters/walk/blend_position",
}

@export var animation_tree: AnimationTree

var interactable: bool = false ## If the NPC can be interacted with
var face_direction: Vector2 = Vector2.DOWN ## Current player direction
var is_moving: bool = false ## If the NPC is currently moving

var _anim_state: AnimationNodeStateMachinePlayback
var _move_path: Line2D
var _waiting: bool = false ## If the NPC is currently waiting before moving again


func _ready() -> void:
	SignalBus.input_paused.connect(_on_interaction)
	_anim_state = animation_tree.get("parameters/playback")
	for child in get_children():
		if child is Line2D:
			_move_path = child
			_move_path.hide()
			break


## Set the NPC as interactable when the InteractionFinder enters it
func _on_area_2d_area_entered(_area: Area2D) -> void:
	interactable = true
	

## Set the NPC as not interactable when the InteractionFinder exits it
func _on_area_2d_area_exited(_area: Area2D) -> void:
	interactable = false


## Make the NPC look at the player
func _on_interaction(paused: bool) -> void:
	set_process(!paused)
	if interactable:
		var player: Node = get_tree().get_first_node_in_group("player")
		var player_direction: Vector2 = player.face_direction
		var npc_direction: Vector2 = Vector2.DOWN
		if player_direction == Vector2.DOWN:
			npc_direction = Vector2.UP
		elif player_direction == Vector2.RIGHT:
			npc_direction = Vector2.LEFT
		elif player_direction == Vector2.LEFT:
			npc_direction = Vector2.RIGHT
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], npc_direction)
		_anim_state.travel("idle")


## Used to move the NPC during a cutscene
func cutscene_move(target_position: Vector2, speed_multiplier: float = 1.0, direction: Vector2 = Vector2.ONE) -> void:
	if direction in [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]:
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], direction)
	_anim_state.travel("walk")
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.25 * speed_multiplier).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	_anim_state.travel("idle")


## Randomly moves the NPC according to the _move_path defined
func _process(_delta: float) -> void:
	if _move_path != null and not is_moving and not _waiting:
		is_moving = true
		var target_position: Vector2 = _get_new_position()
		if position == target_position:
			is_moving = false
			return
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], (position - target_position).normalized() * -1)
		movement_started.emit(Constants.MOVEMENT_STATE.IDLE, Constants.MOVEMENT_STATE.WALKING)
		_anim_state.travel("walk")
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 0.25 * 1).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(_movement_finished)


## Sets the NPC back to idle and waits for a random time before moving again
func _movement_finished() -> void:
	_anim_state.travel("idle")
	movement_finished.emit(Constants.MOVEMENT_STATE.WALKING, Constants.MOVEMENT_STATE.IDLE)
	is_moving = false
	_waiting = true
	await get_tree().create_timer([1, 2, 4].pick_random()).timeout
	_waiting = false


## Gets a new position to move the NPC
func _get_new_position() -> Vector2:
	var valid_positions: Array[Vector2] = []
	var horizontal: Vector2 = Vector2(Constants.TILE_SIZE, 0)
	var vertical: Vector2 = Vector2(0, Constants.TILE_SIZE)
	var positions: Array[Vector2] = [
		position + horizontal,
		position - horizontal,
		position + vertical,
		position - vertical,
	]
	for target_position: Vector2 in positions:
		if target_position in _move_path.points and _can_move(target_position):
			valid_positions.append(target_position)
	if valid_positions.is_empty():
		return position
	return valid_positions.pick_random()


## Checks if the target position isn't being occupied by the player
func _can_move(target_position: Vector2) -> bool:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	var player_position: Vector2 = get_parent().to_local(player.position)
	if player_position.is_equal_approx(target_position):
		return false
	return true
