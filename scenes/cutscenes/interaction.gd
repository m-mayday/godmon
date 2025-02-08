class_name Interaction
extends Cutscene
## Base class for different interactions.
## Based on GDQuest's OpenRPG https://github.com/gdquest-demos/godot-open-rpg


@export var area: Area2D ## Area2D that monitors the interaction

var _is_active: bool = false ## If the current interaction is active or not


func _ready():
	set_process_unhandled_input(false)
	SignalBus.input_paused.connect(_on_input_paused)
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	var player = get_node("../Player")
	assert(player != null, "Player node must be in scene tree")
	player.get_node("GridMovement").movement_finished.connect(_set_is_active_true)
	player.get_node("GridMovement").turning_finished.connect(_set_is_active_true)
	player.get_node("GridMovement").movement_started.connect(_set_is_active_false)
	player.get_node("GridMovement").turning_started.connect(_set_is_active_false)


func _unhandled_input(event: InputEvent) -> void:
	if _is_active and event.is_action_released("interact"):
		run()


## Pause interaction when cutscene is running
func _on_input_paused(paused: bool) -> void:
	area.monitoring = !paused
	area.monitorable = !paused


## Find the entering player's interaction finder and enable input
func _on_area_entered(area: Area2D) -> void:
	_is_active = true
	set_process_unhandled_input(true)


## Disable input when the player's interaction finder exits the area
func _on_area_exited(area: Area2D) -> void:
	_is_active = false
	set_process_unhandled_input(false)


func _set_is_active_false() -> void:
	_is_active = false


func _set_is_active_true() -> void:
	_is_active = true
