extends Area2D

signal movement_started(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)
signal movement_finished(previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE)

const ANIMATION_PARAMETERS: Dictionary[String, String] = {
	"idle": "parameters/idle/blend_position",
	"walk": "parameters/walk/blend_position",
	"run": "parameters/run/blend_position",
	"turn": "parameters/turn/blend_position",
}

@export var speed: float = 0.25
@export var run_speed: float = 0.15
@export var jump_speed: float = 0.20
@export var animation_tree: AnimationTree
@export var raycast: RayCast2D

var moving_direction: Vector2 = Vector2.ZERO
var face_direction: Vector2 = Vector2.DOWN ## Current player direction

var _anim_state: AnimationNodeStateMachinePlayback

var _input_direction: Vector2 = Vector2.ZERO ## Direction in which the player will move
var _current_state: Constants.MOVEMENT_STATE = Constants.MOVEMENT_STATE.IDLE ## Current player state


func _ready():
	# For testing purposes
	var pokemon_party: Array[Pokemon] = []
	pokemon_party.append(Pokemon.new(Constants.SPECIES.VENUSAUR, 60))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.BULBASAUR, 60))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.BLASTOISE, 60))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.CHARIZARD, 60))
	Global.set_player_party_value(0, pokemon_party[0])
	Global.set_player_party_value(1, pokemon_party[1])
	Global.set_player_party_value(2, pokemon_party[2])
	Global.set_player_party_value(3, pokemon_party[3])
	SignalBus.input_paused.connect(_on_input_paused)
	SignalBus.scene_loaded.connect(_on_scene_loaded)
	_anim_state = animation_tree.get("parameters/playback")
	

func _process(_delta: float) -> void:
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	move(_input_direction)


func move(direction: Vector2) -> void:
	# A temporary fix. The player gets "stuck" when turning too many times too fast
	if _current_state == Constants.MOVEMENT_STATE.TURNING and Input.is_action_pressed("cancel"):
		_current_state = Constants.MOVEMENT_STATE.IDLE
		return

	if _current_state == Constants.MOVEMENT_STATE.TURNING or _current_state == Constants.MOVEMENT_STATE.JUMPING:
		return
	elif moving_direction == Vector2.ZERO && direction != Vector2.ZERO:
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], direction)
		var movement: Vector2 = _get_face_direction(direction)
		raycast.target_position = movement * Constants.TILE_SIZE / 2
		raycast.force_raycast_update() # Update the `target_position` immediately
		
		var previous_state: Constants.MOVEMENT_STATE = _current_state
		if _need_to_turn(direction):
			_current_state = Constants.MOVEMENT_STATE.TURNING
			movement_started.emit(previous_state, _current_state)
			_anim_state.travel("turn")
			return
		
		var current_speed: float = speed
		
		# Allow movement only if no collision in next tile
		if !raycast.is_colliding():

			moving_direction = movement
			
			var new_position = global_position + (moving_direction * Constants.TILE_SIZE)
			if Input.is_action_pressed("cancel"):
				current_speed = run_speed
				_current_state = Constants.MOVEMENT_STATE.RUNNING
				_anim_state.travel("run")
			else:
				_current_state = Constants.MOVEMENT_STATE.WALKING
				_anim_state.travel("walk")
			
			movement_started.emit(previous_state, _current_state)
			var tween: Tween = create_tween()
			tween.tween_property(self, "position", new_position, current_speed).set_trans(Tween.TRANS_LINEAR)
			tween.tween_callback(_movement_finsished)
		else:
			_handle_collision(movement)


## Moves player to the target position by walking speed * multiplier provided.
## It doesn't emit any movement signals and it's useful for cutscenes (thus the name).
func cutscene_move(target_position: Vector2, speed_multiplier: float = 1.0, face_direction: Vector2 = Vector2.ONE) -> void:
	if face_direction in [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]:
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], face_direction)
	_anim_state.travel("walk")
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, speed * speed_multiplier).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	_anim_state.travel("idle")
	_current_state = Constants.MOVEMENT_STATE.IDLE


## Gets new facing direction according to input
func _get_face_direction(direction: Vector2) -> Vector2:
	if direction.x < 0:
		return Vector2.LEFT
	elif direction.x > 0:
		return Vector2.RIGHT
	elif direction.y < 0:
		return Vector2.UP
	elif direction.y > 0:
		return Vector2.DOWN
	return face_direction


## Determines if the player will change direction and needs to turn
func _need_to_turn(direction: Vector2) -> bool:
	var new_face_direction: Vector2 = _get_face_direction(direction)
	if new_face_direction != face_direction:
		face_direction = new_face_direction
		return true
	return false


## Called after node stops moving
func _movement_finsished() -> void:
	moving_direction = Vector2.ZERO
	var previous_state: Constants.MOVEMENT_STATE = _current_state
	_current_state = Constants.MOVEMENT_STATE.IDLE
	_anim_state.travel("idle")
	movement_finished.emit(previous_state, _current_state)


## Checks for certain collisions and handles them (ledges, doors, stairs, etc.)
func _handle_collision(movement: Vector2) -> void:
	var collider: Object = raycast.get_collider()
	if _should_jump(movement):
		var mid_position: Vector2 = position
		if movement == Vector2.LEFT or movement == Vector2.RIGHT:
			mid_position.x += (Constants.TILE_SIZE / 2) * movement.x

		moving_direction = movement
		
		var new_position: Vector2 = global_position + (moving_direction * Constants.TILE_SIZE * 2)
		var previous_state: Constants.MOVEMENT_STATE = _current_state
		_current_state = Constants.MOVEMENT_STATE.JUMPING
		_anim_state.travel("walk")
		movement_started.emit(previous_state, _current_state)
		mid_position.y -= Constants.TILE_SIZE / 2  # Move up slightly

		var tween: Tween = create_tween()
		tween.tween_property(self, "position", mid_position, jump_speed)
		tween.tween_property(self, "position", new_position, jump_speed)
		tween.tween_callback(_movement_finsished)
	elif collider.get_parent() is Door:
		var door: Door = collider.get_parent()
		door.execute()
	elif collider is Stairs:
		var stairs: Stairs = collider as Stairs
		stairs.execute()


## Determines if the player is colliding with a ledge and should jump it
func _should_jump(movement: Vector2) -> bool:
	var collider: Object = raycast.get_collider()
	if collider is TileMapLayer:
		var layer: TileMapLayer = collider as TileMapLayer
		if layer.tile_set.get_custom_data_layer_by_name("ledge") == -1:
			return false
		var body_rid: RID = raycast.get_collider_rid()
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
				var original_position: Vector2 = raycast.position
				raycast.position += movement * Constants.TILE_SIZE
				raycast.force_raycast_update()
				if raycast.is_colliding():
					can_jump = false
				raycast.position = original_position
				raycast.force_raycast_update()
			return can_jump
	return false


func _on_input_paused(paused: bool):
	set_process(!paused)


## Player could be invisible due to a different script
## so make him visible when a new scene is loaded
func _on_scene_loaded(_previous_scene: String, _new_scene: String) -> void:
	visible = true
