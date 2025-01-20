extends Node2D

signal movement_started
signal movement_finished
signal turning_started
signal turning_finished

enum STATE {IDLE, WALKING, RUNNING, TURNING}
enum DIRECTION {UP, DOWN, RIGHT, LEFT}

const ANIMATION_PARAMETERS: Dictionary[String, String] = {
	"idle": "parameters/idle/blend_position",
	"walk": "parameters/walk/blend_position",
	"run": "parameters/run/blend_position",
	"turn": "parameters/turn/blend_position",
}

@export var entity: Node2D
@export var speed: float = 0.25
@export var run_speed: float = 0.15
@export var animation_tree: AnimationTree

var moving_direction: Vector2 = Vector2.ZERO

var _current_state: STATE = STATE.IDLE ## Current node state
var _face_direction: DIRECTION = DIRECTION.DOWN ## Current node direction

@onready var _anim_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _ready():
	animation_tree.animation_finished.connect(_animation_finished)


func move(direction: Vector2) -> void:
	if _current_state == STATE.TURNING:
		return
	elif moving_direction == Vector2.ZERO && direction != Vector2.ZERO:
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], direction)
		var movement = Vector2.DOWN
		if direction.y > 0: movement = Vector2.DOWN
		elif direction.y < 0: movement = Vector2.UP
		elif direction.x > 0: movement = Vector2.RIGHT
		elif direction.x < 0: movement = Vector2.LEFT
		$RayCast2D.target_position = movement * Constants.TILE_SIZE / 2
		$RayCast2D.force_raycast_update() # Update the `target_position` immediately
		
		if _need_to_turn(direction):
			_current_state = STATE.TURNING
			turning_started.emit()
			_anim_state.travel("turn")
			return
		
		# Allow movement only if no collision in next tile
		if !$RayCast2D.is_colliding():
			var current_speed = speed

			moving_direction = movement
			
			var new_position = entity.global_position + (moving_direction * Constants.TILE_SIZE)
			if Input.is_action_pressed("cancel"):
				current_speed = run_speed
				_current_state = STATE.RUNNING
				_anim_state.travel("run")
			else:
				_current_state == STATE.WALKING
				_anim_state.travel("walk")
			
			movement_started.emit()
			var tween = create_tween()
			tween.tween_property(entity, "position", new_position, current_speed).set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(_movement_finsished)


## Gets new facing direction according to input
func _get_face_direction(direction: Vector2) -> DIRECTION:
	if direction.x < 0:
		return DIRECTION.LEFT
	elif direction.x > 0:
		return DIRECTION.RIGHT
	elif direction.y < 0:
		return DIRECTION.UP
	elif direction.y > 0:
		return DIRECTION.DOWN
	return _face_direction


## Determines if the player will change direction and needs to turn
func _need_to_turn(direction: Vector2) -> bool:
	var new_face_direction: DIRECTION = _get_face_direction(direction)
	if new_face_direction != _face_direction:
		_face_direction = new_face_direction
		return true
	return false


## Called after node stops moving
func _movement_finsished() -> void:
	moving_direction = Vector2.ZERO
	_current_state = STATE.IDLE
	_anim_state.travel("idle")
	movement_finished.emit()


## Used to set the state back to IDLE when node stops turning
func _animation_finished(anim: StringName) -> void:
	if anim.begins_with("turn"):
		_current_state = STATE.IDLE
		turning_finished.emit()
