extends Cutscene

@export var area: Area2D
@export var collision: CollisionShape2D ## The collision that will detect the player. Will be freed if trainer has been defeated
@export var trainer: Trainer
@export var entity: Node2D ## The entity that "owns" this trainer (usually an NPC)
@export var map: Node2D ## Used to move the entity to the player with the right coordinates

## Actions to run when the trainer sees the player (i.e: exclamation mark, walk to the player)
@export var on_seen_actions: Array[EventAction]

## Actions to run right before starting the battle (i.e: trainer banner)
@export var battle_setup_actions: Array[EventAction]

## If provided, battle setup actions will be ran when this dialogue ends.
## Used in case the player interacts with the trainer without them being seen.
@export var start_on_dialogue: DialogueResource

var player: Area2D

## The way the battle has triggered
var triggered_by_dialogue: bool = false
var triggered_by_sight: bool = false


func _ready():
	if trainer.get_defeat_count() <= 0:
		set_process_unhandled_input(false)
		SignalBus.input_paused.connect(_on_input_paused)
		if start_on_dialogue != null:
			DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		area.area_entered.connect(_on_area_entered)
		if entity != null and entity.has_signal("face_direction_changed"):
			entity.face_direction_changed.connect(_set_direction)


## Pause interaction when cutscene is running
func _on_input_paused(paused: bool) -> void:
	area.set_deferred("monitoring", !paused)
	area.set_deferred("monitorable", !paused)
	

## Move the area in the specified direction
func _set_direction(direction: Vector2) -> void:
	match direction:
		Vector2.DOWN:
			area.rotation_degrees = 0.0
		Vector2.UP:
			area.rotation_degrees = 180.0
		Vector2.LEFT:
			area.rotation_degrees = 90.0
		Vector2.RIGHT:
			area.rotation_degrees = -90.0
			

## Start battle when player enters area, if possible
func _on_area_entered(entered_area: Area2D) -> void:
	if _is_cutscene_in_progress or triggered_by_dialogue:
		return
	player = entered_area
	triggered_by_sight = true
	if player._current_state == Constants.MOVEMENT_STATE.IDLE:
		await run()
	else:
		player.movement_finished.connect(run.unbind(2), CONNECT_ONE_SHOT)


func _execute() -> void:
	if not triggered_by_dialogue:
		await _run_seen_actions()
	await _run_battle_setup_actions()
	_start_battle()


## Moves the entity to the player
func move_to_player() -> void:
	var vector_distance: Vector2 = abs(map.to_global(entity.position) - player.position) / Constants.TILE_SIZE
	var tile_distance: int = maxi(vector_distance.x, vector_distance.y) - 1
	if tile_distance <= 0:
		return
	var direction: Vector2 = (map.to_global(entity.position) - player.position).normalized() * -1
	for tile in range(tile_distance):
		await entity.walk((entity.position + (direction * Constants.TILE_SIZE)).snapped(Vector2.ONE * Constants.TILE_SIZE))


## Runs action when trainer sees the player
func _run_seen_actions() -> void:
	for action in on_seen_actions:
		await action.execute(self)
		if not action.wait_after.is_empty():
			await get_tree().create_timer(action.wait_after.pick_random()).timeout


## Runs actions just before starting the battle
func _run_battle_setup_actions() -> void:
	for action in battle_setup_actions:
		await action.execute(self)
		if not action.wait_after.is_empty():
			await get_tree().create_timer(action.wait_after.pick_random()).timeout


## Starts the battle
func _start_battle() -> void:
	get_tree().root.get_node("Main").load_scene("res://scenes/battle/battle_scene.tscn", false, true, ["wild", get_tree().get_first_node_in_group("player"), trainer.party])


## Checks if battle should be triggered by dialogue (i.e, the player talks to the trainer without being spotted)
func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == start_on_dialogue and not triggered_by_sight:
		if trainer.get_defeat_count() > 0:
			return
		triggered_by_dialogue = true
		run()


## Frees the collision so it's not possible to trigger the battle by sight
func _on_tree_entered() -> void:
	if trainer.get_defeat_count() > 0:
		if collision != null:
			collision.queue_free()
		if triggered_by_dialogue or triggered_by_sight:
			if "movement_type" in entity:
				entity.movement_type = 0 ## Stop moving after battle
