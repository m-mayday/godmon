extends CanvasLayer

signal screen_closed

enum CONTEXT {OVERWORLD, BATTLE}

@export var context: CONTEXT = CONTEXT.OVERWORLD
@export var slots_container: Node
@export var slot_options: VBoxContainer
@export var cancel_button: TextureButton

var _cancel_texture: Texture2D ## Normal cancel texture to change on focus
var _selected_slot_index: int ## The selected Pokemon slot index


func _ready() -> void:
	_cancel_texture = cancel_button.texture_normal
	_set_up_slots()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or event.is_action_pressed("ui_cancel"):
		screen_closed.emit()


func _on_cancel_pressed() -> void:
	screen_closed.emit()


func _on_cancel_focus_entered() -> void:
	cancel_button.texture_normal = cancel_button.texture_focused


func _on_cancel_focus_exited() -> void:
	cancel_button.texture_normal = _cancel_texture
	

## Show the options for the current selected slot
func _on_party_slot_pressed(index: int) -> void:
	_selected_slot_index = index
	cancel_button.hide()
	%SlotOptions.show()
	slot_options.get_child(0).grab_focus()


## Prepare the slots to show Pokemon information
func _set_up_slots() -> void:
	assert(len(Global.player_party) >= 0 and len(Global.player_party) <= 6, "Parties of more than 6 pokemon not supported.")
	var slots: Array[Node] = slots_container.get_children()
	for slot in slots:
		slot.context = context
	slots_container.get_child(0).grab_focus()


func _on_slot_cancel_pressed() -> void:
	cancel_button.show()
	%SlotOptions.hide()
	slots_container.get_child(_selected_slot_index).grab_focus()


func _on_visibility_changed() -> void:
	if visible:
		slots_container.get_child(0).grab_focus()
