extends NinePatchRect
## Menu in battle to choose an action

signal switch_pressed
signal fight_pressed
signal run_pressed

@export var options_container: GridContainer


## Remember last selected option to grab focus next time
var _last_selected: int = 0


func _ready():
	options_container.get_child(0).grab_focus()


func _on_draw():
	# Grabs focus of the last_selected option when menu appears on screen
	options_container.get_child(_last_selected).grab_focus()


## Changes the last_selected to switch option and emits switch_pressed
func _on_switch_pressed() -> void:
	_last_selected = 2
	switch_pressed.emit()


## Changes the last_selected to fight option and emits fight_pressed
func _on_fight_pressed() -> void:
	_last_selected = 0
	fight_pressed.emit()


## Changes the last_selected to fight option and emits run_pressed
func _on_run_pressed() -> void:
	_last_selected = 3
	run_pressed.emit()
