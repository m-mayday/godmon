extends CanvasLayer

signal screen_closed

@onready var _cancel_button: TextureButton = %Cancel

var party: Array[Pokemon] = [] ## Array of Pokemon to display
var _cancel_texture: Texture2D ## Normal cancel texture to change on focus
var _selected_slot_index: int ## The selected Pokemon slot index


func _ready() -> void:
	_cancel_texture = _cancel_button.texture_normal


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or event.is_action_pressed("ui_cancel"):
		screen_closed.emit()


func _on_cancel_pressed() -> void:
	screen_closed.emit()


func _on_cancel_focus_entered() -> void:
	_cancel_button.texture_normal = _cancel_button.texture_focused


func _on_cancel_focus_exited() -> void:
	_cancel_button.texture_normal = _cancel_texture
	

## Show the options for the current selected slot
func _on_party_slot_pressed(index: int) -> void:
	_selected_slot_index = index
	_cancel_button.hide()
	%SlotOptions.show()
	%SlotOptions/NinePatchRect/MarginContainer/VBoxContainer.get_child(0).grab_focus()


## Prepare the slots to show Pokemon information
func _set_up_slots() -> void:
	assert(len(party) >= 0 and len(party) <= 6, "Parties of more than 6 pokemon not supported.")
	var slots: Array[Node] = $Control/Background/Slots.get_children()
	var pokemon_count: int = party.size()
	for i: int in range(pokemon_count):
		slots[i].pokemon = party[i]
		slots[i].show()
	if pokemon_count > 0:
		await get_tree().process_frame # Needed to grab focus correctly
		$Control/Background/Slots/PartySlotMain.grab_focus()


func _on_visibility_changed() -> void:
	if visible:
		_set_up_slots()


func _on_slot_cancel_pressed() -> void:
	_cancel_button.show()
	%SlotOptions.hide()
	$Control/Background/Slots.get_child(_selected_slot_index).grab_focus()
