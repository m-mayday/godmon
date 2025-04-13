extends Sprite2D

signal movement_started(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)
signal movement_finished(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)

enum MOVEMENT_TYPE {
	NONE, ## Standing still, looking in a single direction.
	FIXED_RANDOM, ## Standing still, but turning randomly.
	PATH_FOLLOW, ## Follow the specified path.
	PATH_RANDOM, ## Move randomly on the specified path, without turning.
	PATH_RANDOM_WITH_TURN, ## Move and turn randomly on the path. Moving is more likely than turning.
	SEQUENCE, ## Follow the movement specified by [code]sequence[/code].
}

const ANIMATION_PARAMETERS: Dictionary[String, String] = {
	"idle": "parameters/idle/blend_position",
	"walk": "parameters/walk/blend_position",
}


@export var animation_tree: AnimationTree
@export var face_direction: Vector2 = Vector2.DOWN ## NPC's direction.
@export var movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.NONE: ## How this NPC moves.
	set = _set_movement_type
@export var sequence: Array[MovementAction] ## Sequence of actions used if [code]movement_type = MOVEMENT_TYPE.SEQUENCE[/code].

## An array of seconds to wait before the next movement is executed. Picked at random.
## If [code]movement_type = MOVEMENT_TYPE.SEQUENCE[/code], then the [code]wait_after[/code] of each action is used instead.
@export var wait_seconds_choices: Array[float] = [1, 2, 3]

var interactable: bool = false ## If the NPC can be interacted with.
var is_moving: bool = false ## If the NPC is currently moving.
var next_position: Vector2 ## The position the NPC will be moving to.
var previous_position: Vector2 ## The position the NPC is moving from.
var directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT] ## Possible directions to turn.

var _anim_state: AnimationNodeStateMachinePlayback
var _move_path: Line2D ## The path the NPC moves on
var _last_point_index: int = 0 ## Last index of certain movement options.
var _looping_backwards: bool = false ## Used for [code]MOVEMENT_TYPE.PATH_FOLLOW[/code], to loop the movement back and forth.
var _is_waiting: bool = false ## If the NPC is currently waiting before moving again.
var _rng = RandomNumberGenerator.new() ## Used for [code]MOVEMENT_TYPE.PATH_RANDOM_WITH_TURN[/code] to decide if NPC should walk or turn.
var _move: Callable ## The movement function to execute according to [code]movement_type[/code].

func _ready() -> void:
	SignalBus.input_paused.connect(_on_interaction)
	_anim_state = animation_tree.get("parameters/playback")
	for child in get_children():
		if child is Line2D:
			_move_path = child
			_move_path.hide()
			break
	next_position = position
	previous_position = position


## Randomly moves the NPC according to the _move_path defined
func _process(_delta: float) -> void:
	if is_moving or _is_waiting or movement_type == MOVEMENT_TYPE.NONE:
		return
	_move.call()

## Walks to the target position, if possible.
func walk(target_position: Vector2) -> bool:
	if not _can_move(target_position):
		return false
	face_direction = (position - target_position).normalized() * -1
	_set_animation_parameters(face_direction)
	previous_position = position
	next_position = target_position
	is_moving = true
	movement_started.emit(Constants.MOVEMENT_STATE.IDLE, Constants.MOVEMENT_STATE.WALKING)
	_anim_state.travel("walk")
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.25 * 1).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	# Calling _movement_finished directly instead of relying on tween_callback prevents weird desync
	# when running parallel actions and Engine.time_scale > 1
	_movement_finished()
	return true

## Turns to the provided direction.
func turn(direction: Vector2) -> void:
	_set_animation_parameters(direction)
	is_moving = true
	_anim_state.travel("idle")
	_movement_finished()


## Set [code]_move[/code] to the corresponding function.
func _set_movement_type(value: MOVEMENT_TYPE) -> void:
	match value:
		MOVEMENT_TYPE.FIXED_RANDOM:
			_move = _movement_type_fixed_random
		MOVEMENT_TYPE.PATH_FOLLOW:
			_move = _movement_type_path_follow
		MOVEMENT_TYPE.PATH_RANDOM:
			_move = _movement_type_path_random
		MOVEMENT_TYPE.PATH_RANDOM_WITH_TURN:
			_move = _movement_type_path_random_turn
		MOVEMENT_TYPE.SEQUENCE:
			_move = _movement_type_sequence
	movement_type = value


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


## Sets the NPC back to idle and waits for a random time before moving again
func _movement_finished() -> void:
	_anim_state.travel("idle")
	movement_finished.emit(Constants.MOVEMENT_STATE.WALKING, Constants.MOVEMENT_STATE.IDLE)
	is_moving = false
	_is_waiting = true
	previous_position = position
	if wait_seconds_choices.is_empty():
		_is_waiting = false
		return
	await get_tree().create_timer(wait_seconds_choices.pick_random()).timeout
	_is_waiting = false


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
	var main: Node2D = get_tree().root.get_node("Main")
	if main.will_collide_with_player(get_parent().to_global(target_position)):
		return false
	return true
	

func _movement_type_fixed_random() -> void:
	directions.shuffle()
	for direction in directions:
		if direction != face_direction:
			face_direction = direction
			break
	_set_animation_parameters(face_direction)
	is_moving = true
	_anim_state.travel("idle")
	_movement_finished()


func _movement_type_path_follow() -> void:
	if _move_path != null:
		var _next_index: int = _last_point_index
		if _move_path.closed:
			_next_index = wrapi(_next_index+1, 0, _move_path.get_point_count())
		else:
			var multiplier: int = 1
			if _looping_backwards:
				multiplier = -1
			_next_index = _next_index + (1 * multiplier)
			
		var point: Vector2 = _move_path.get_point_position(_next_index)
		
		if not _can_move(point):
			return
		
		if _next_index >= _move_path.get_point_count()-1 or _next_index <= 0:
			_looping_backwards = !_looping_backwards
		
		previous_position = position
		next_position = point
		_last_point_index = _next_index
		face_direction = (position - point).normalized() * -1
		_set_animation_parameters(face_direction)
		previous_position = position
		next_position = point
		is_moving = true
		movement_started.emit(Constants.MOVEMENT_STATE.IDLE, Constants.MOVEMENT_STATE.WALKING)
		_anim_state.travel("walk")
		var tween = create_tween()
		tween.tween_property(self, "position", point, 0.25 * 1).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(_movement_finished)


func _movement_type_path_random() -> void:
	if _move_path != null:
		var target_position: Vector2 = _get_new_position()
		if position == target_position:
			return
		face_direction = (position - target_position).normalized() * -1
		_set_animation_parameters(face_direction)
		previous_position = position
		next_position = target_position
		is_moving = true
		movement_started.emit(Constants.MOVEMENT_STATE.IDLE, Constants.MOVEMENT_STATE.WALKING)
		_anim_state.travel("walk")
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 0.25 * 1).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(_movement_finished)


func _movement_type_path_random_turn() -> void:
	if _move_path != null:
		var movement: Array[Constants.MOVEMENT_STATE] = [Constants.MOVEMENT_STATE.TURNING, Constants.MOVEMENT_STATE.WALKING]
		if movement[_rng.rand_weighted([0.3, 0.7])] == Constants.MOVEMENT_STATE.WALKING:
			_movement_type_path_random()
		else:
			_movement_type_fixed_random()


func _movement_type_sequence() -> void:
	if not sequence.is_empty():
		var current_index: int = _last_point_index
		var action: MovementAction = sequence[_last_point_index]
		_last_point_index = wrapi(_last_point_index+1, 0, sequence.size())
		wait_seconds_choices = action.wait_after
		var executed: bool = await action.execute(self)
		if not executed:
			_last_point_index = current_index


func _set_animation_parameters(direction: Vector2):
	for key in ANIMATION_PARAMETERS.keys():
		animation_tree.set(ANIMATION_PARAMETERS[key], direction)
