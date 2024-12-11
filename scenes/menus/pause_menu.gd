extends CanvasLayer

@onready var menu = $Control

func _ready() -> void:
	menu.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		menu.show()
		$Control/NinePatchRect/MarginContainer/VBoxContainer/Pokedex.grab_focus()
		get_tree().paused = true
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	elif event.is_action_pressed("cancel"):
		menu.hide()
		get_tree().paused = false
		process_mode = Node.PROCESS_MODE_PAUSABLE


## Stops handling input
func _on_prevent_pausing() -> void:
	set_process_unhandled_input(false)


## Resumes handling input
func _on_allow_pausing() -> void:
	set_process_unhandled_input(true)
