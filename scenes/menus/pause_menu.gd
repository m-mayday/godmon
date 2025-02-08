extends CanvasLayer

@export var menu: Control
@export var options_container: VBoxContainer


## The scenes to be shown when a button is pressed. To be set from the editor.
@export var screens: Dictionary[String, PackedScene] = {
	"pokedex": null,
	"pokemon": null,
}

## The buttons that are part of the menu. To be set from the editor
@export var options: Dictionary[String, Button] = {
	"pokedex": null,
	"pokemon": null,
}

var _current_screen: Node = null ## Current screen being shown
var _selected_option: Button = null ## Current option that was selected, to grab focus when menu is shown again.


func _ready() -> void:
	SignalBus.input_paused.connect(_on_input_paused)
	menu.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not menu.visible:
		var first_option: Node = _get_first_visible_option()
		if first_option == null:
			return # Don't open menu if there are no visible options in it
		menu.show()
		first_option.grab_focus()
		get_tree().paused = true
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	elif event.is_action_pressed("cancel") and menu.visible:
		menu.hide()
		get_tree().paused = false
		process_mode = Node.PROCESS_MODE_PAUSABLE


## Stops handling input
func _on_prevent_pausing() -> void:
	set_process_unhandled_input(false)


## Resumes handling input
func _on_allow_pausing() -> void:
	set_process_unhandled_input(true)
	
	
func _on_input_paused(paused: bool) -> void:
	set_process_unhandled_input(!paused)


## Instantiate the right screen when an option is pressed
func _on_option_pressed(screen_name: String) -> void:
	var screen_scene: PackedScene = screens.get(screen_name, null)
	if screen_name != null:
		var screen: Node = screen_scene.instantiate()
		if screen.has_signal("screen_closed"):
			_current_screen = screen
			_selected_option = options[screen_name]
			screen.screen_closed.connect(_on_screen_closed)
			set_process_unhandled_input(false)
			add_child(screen)
		else:
			screen.queue_free() # Screens without the screen_closed signal are not valid


## Free the current screen and show the pause menu again.
func _on_screen_closed() -> void:
	if _current_screen != null:
		_current_screen.queue_free()
		_selected_option.grab_focus()
		set_process_unhandled_input(true)


## Get the first visible button/option in the menu
func _get_first_visible_option() -> Node:
	var buttons: Array[Node] = options_container.get_children()
	for button in buttons:
		if button.visible:
			return button
	return null
