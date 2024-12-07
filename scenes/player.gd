extends Area2D

signal player_moved ## Emitted when the player starts moving
signal player_stopped ## Emitted when the player stops moving

enum PLAYER_STATE {IDLE, WALKING, RUNNING, TURNING}
enum FACE_DIRECTION {UP, DOWN, RIGHT, LEFT}


const ANIMATION_PARAMETERS: Dictionary[String, String] = {
	"idle": "parameters/idle/blend_position",
	"walk": "parameters/walk/blend_position",
	"run": "parameters/run/blend_position",
	"turn": "parameters/turn/blend_position",
}


## Different movement speeds according to player's current state.
## Will use default_move_speed if not defined here.
const MOVEMENT_SPEED: Dictionary[PLAYER_STATE, float] = {
	PLAYER_STATE.RUNNING: 8.0,
	# Can add bike, surf, etc.
}

@export var tile_size: int = 16  ## Will probably be moved to a setting
@export var default_move_speed: float = 4.0 ## Default moving speed (Walking)

@onready var _anim: AnimationTree = $AnimationTree
@onready var _raycast: RayCast2D = $RayCast2D
@onready var _anim_state: AnimationNodeStateMachinePlayback = _anim.get("parameters/playback")


var _initial_position: Vector2 = Vector2.ZERO ## Player's initial position before moving
var _input_direction: Vector2 = Vector2.ZERO ## Direction in which the player will move
var _is_moving: bool = false ## If the player is currently moving or not
var _percent_to_next_tile: float = 0.0 ## The percentage traveled to the next tile
var _player_state: PLAYER_STATE = PLAYER_STATE.IDLE ## Current player state
var _face_direction: FACE_DIRECTION = FACE_DIRECTION.DOWN ## Current player direction


func _ready():
	_initial_position = position
	

func _physics_process(delta: float) -> void:
	if _player_state == PLAYER_STATE.TURNING:
		return
	elif not _is_moving:
		_process_player_input()
	elif _input_direction != Vector2.ZERO:
		if Input.is_action_pressed("ui_accept"):
			_player_state = PLAYER_STATE.RUNNING
			_anim_state.travel("run")
		else:
			_player_state = PLAYER_STATE.WALKING
			_anim_state.travel("walk")
		_move(delta)
	else:
		_anim_state.travel("idle")
		_is_moving = false


## Processes player input and moves the character if necessary
func _process_player_input() -> void:
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if _input_direction != Vector2.ZERO:
		for key in ANIMATION_PARAMETERS.keys():
			_anim.set(ANIMATION_PARAMETERS[key], _input_direction)
		var desired_step: Vector2 = _input_direction * tile_size / 2
		_raycast.target_position = desired_step
		_raycast.force_raycast_update()
		if _need_to_turn():
			_player_state = PLAYER_STATE.TURNING
			_anim_state.travel("turn")
		else:
			_initial_position = position
			_is_moving = true
	else:
		_anim_state.travel("idle")


## Moves the player if not colliding and emits movings signals
func _move(delta: float) -> void:
	if _raycast.is_colliding():
		if _percent_to_next_tile > 0.0:
			# Player can collide while moving, so this needs to emitted
			player_stopped.emit() 
		_percent_to_next_tile = 0.0
		_is_moving = false
		return

	if _percent_to_next_tile == 0.0:
		player_moved.emit() # Player will start moving

	var speed: float = MOVEMENT_SPEED.get(_player_state, default_move_speed)
	_percent_to_next_tile +=  speed * delta
	if _percent_to_next_tile >= 1.0:
		position = _initial_position + (tile_size * _input_direction)
		_percent_to_next_tile = 0.0
		_is_moving = false
		player_stopped.emit()
	else:
		position = _initial_position.lerp(_initial_position + _input_direction * tile_size, _percent_to_next_tile)


## Gets new facing direction according to input
func _get_face_direction(direction: Vector2) -> FACE_DIRECTION:
	if direction.x < 0:
		return FACE_DIRECTION.LEFT
	elif direction.x > 0:
		return FACE_DIRECTION.RIGHT
	elif direction.y < 0:
		return FACE_DIRECTION.UP
	elif direction.y > 0:
		return FACE_DIRECTION.DOWN
	return _face_direction


## Determines if the player will change direction and needs to turn
func _need_to_turn() -> bool:
	var new_face_direction: FACE_DIRECTION = _get_face_direction(_input_direction)
	if new_face_direction != _face_direction:
		_face_direction = new_face_direction
		return true
	return false


## Called by the AnimationPlayer when turning animation finishes
func finished_turning() -> void:
	_player_state = PLAYER_STATE.IDLE
