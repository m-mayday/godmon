extends Node2D

signal movement_started(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)
signal movement_finished(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)

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

var _current_state: Constants.MOVEMENT_STATE = Constants.MOVEMENT_STATE.IDLE ## Current node state
var _face_direction: DIRECTION = DIRECTION.DOWN ## Current node direction

@onready var _anim_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _ready():
	animation_tree.animation_finished.connect(_animation_finished)


func move(direction: Vector2) -> void:
	if _current_state == Constants.MOVEMENT_STATE.TURNING or _current_state == Constants.MOVEMENT_STATE.JUMPING:
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
		
		var previous_state: Constants.MOVEMENT_STATE = _current_state
		if _need_to_turn(direction):
			_current_state = Constants.MOVEMENT_STATE.TURNING
			movement_started.emit(previous_state, _current_state)
			_anim_state.travel("turn")
			return
		
		# Allow movement only if no collision in next tile
		if !$RayCast2D.is_colliding():
			var current_speed = speed

			moving_direction = movement
			
			var new_position = entity.global_position + (moving_direction * Constants.TILE_SIZE)
			if Input.is_action_pressed("cancel"):
				current_speed = run_speed
				_current_state = Constants.MOVEMENT_STATE.RUNNING
				_anim_state.travel("run")
			else:
				_current_state = Constants.MOVEMENT_STATE.WALKING
				_anim_state.travel("walk")
			
			movement_started.emit(previous_state, _current_state)
			var tween = create_tween()
			tween.tween_property(entity, "position", new_position, current_speed).set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(_movement_finsished)
		elif _should_jump(movement):
				var mid_position: Vector2 = entity.position
				if movement == Vector2.LEFT or movement == Vector2.RIGHT:
					mid_position.x += (Constants.TILE_SIZE / 2) * movement.x

				moving_direction = movement
				
				var new_position = entity.global_position + (moving_direction * Constants.TILE_SIZE * 2)
				_current_state = Constants.MOVEMENT_STATE.JUMPING
				_anim_state.travel("walk")
				movement_started.emit(previous_state, _current_state)
				mid_position.y -= Constants.TILE_SIZE / 2  # Move up slightly

				var tween = create_tween()
				tween.tween_property(entity, "position", mid_position, 0.2)
				tween.tween_property(entity, "position", new_position, 0.2)
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
	var previous_state: Constants.MOVEMENT_STATE = _current_state
	_current_state = Constants.MOVEMENT_STATE.IDLE
	_anim_state.travel("idle")
	movement_finished.emit(previous_state, _current_state)


## Used to set the state back to IDLE when node stops turning
func _animation_finished(anim: StringName) -> void:
	if anim.begins_with("turn"):
		_current_state = Constants.MOVEMENT_STATE.IDLE
		movement_finished.emit(Constants.MOVEMENT_STATE.TURNING, _current_state)


## Determines if the player is colliding with a ledge and should jump it
func _should_jump(movement: Vector2) -> bool:
	var collider: Object = $RayCast2D.get_collider()
	if collider is TileMapLayer:
		var layer: TileMapLayer = collider as TileMapLayer
		var body_rid: RID = $RayCast2D.get_collider_rid()
		var cell_data: TileData = layer.get_cell_tile_data(layer.get_coords_for_body_rid(body_rid))
		var data: Variant = cell_data.get_custom_data("ledge")
		var ledge: Vector2 = Vector2.ZERO
		if data != null:
			ledge = data as Vector2
		if ledge != Vector2.ZERO:
			var can_jump: bool = false
			if movement == Vector2.LEFT and ledge.x == -1: can_jump = true
			elif movement == Vector2.RIGHT and ledge.x == 1: can_jump = true
			elif movement == Vector2.DOWN and ledge.y == 1: can_jump = true
			elif movement == Vector2.UP and ledge.y == -1: can_jump = true
			
			## Verify there's no collision on the other side of the ledge
			if can_jump:
				var original_position: Vector2 = $RayCast2D.position
				$RayCast2D.position += movement * Constants.TILE_SIZE
				$RayCast2D.force_raycast_update()
				if $RayCast2D.is_colliding():
					can_jump = false
				$RayCast2D.position = original_position
				$RayCast2D.force_raycast_update()
			return can_jump
	return false
