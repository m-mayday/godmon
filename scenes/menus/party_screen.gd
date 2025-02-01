extends CanvasLayer

signal screen_closed
signal switch(switch_out: Battler, switch_in: Battler, is_instant_switch: bool)

enum CONTEXT {
	OVERWORLD,
	BATTLE,
}

@export var context: CONTEXT = CONTEXT.OVERWORLD
@export var slots_container: Node
@export var slot_options: VBoxContainer
@export var cancel_button: TextureButton
@export var send_out_option: Button
@export var summary_option: Button
@export var switch_option: Button
@export var item_option: Button


var _cancel_texture: Texture2D ## Normal cancel texture to change on focus
var _selected_slot_index: int ## The selected Pokemon slot index
var _switch_out_battler: Battler ## Battler that is switching out
var _is_instant_switch: bool ## If an instant switch has been requested


func _ready() -> void:
	_cancel_texture = cancel_button.texture_normal
	_set_up_slots()
	if context == CONTEXT.BATTLE:
		SignalBus.battler_ready.connect(_on_battler_ready)


func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("cancel") or event.is_action_pressed("ui_cancel"):
			screen_closed.emit()


## A battler needs to be switched in, so show the menu
func request_switch(event: RequestSwitchEvent):
	show()
	_switch_out_battler = event.battler
	_is_instant_switch = event.is_instant_switch


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
	_grab_slot_option_focus(_get_first_visible_slot_option())


## Prepare the slots to show Pokemon information
func _set_up_slots() -> void:
	assert(len(Global.player_party) >= 0 and len(Global.player_party) <= 6, "Parties of more than 6 pokemon not supported.")
	var slots: Array[Node] = slots_container.get_children()
	for slot in slots:
		slot.context = context
	send_out_option.visible = context == CONTEXT.BATTLE
	switch_option.visible = context != CONTEXT.BATTLE
	item_option.visible = context != CONTEXT.BATTLE
	slots_container.get_child(0).grab_focus()


func _on_slot_cancel_pressed() -> void:
	cancel_button.show()
	%SlotOptions.hide()
	slots_container.get_child(_selected_slot_index).grab_focus()


func _on_visibility_changed() -> void:
	if visible:
		slots_container.get_child(0).grab_focus()
	else:
		%SlotOptions.hide()
		cancel_button.show()


## Get the first visible slot option (usually to grab focus)
func _get_first_visible_slot_option() -> Button:
	for option in slot_options.get_children():
		if option.visible:
			return option
	return null


func _grab_slot_option_focus(option: Button) -> void:
	if option != null:
		option.grab_focus()


## Check if battler can be send out
func _on_send_out_pressed() -> void:
	var battler: Battler = Global.get_player_battler(_selected_slot_index)
	if battler == null:
		return
	var switch_in: Array = battler.can_switch_in()
	if switch_in[0]:
		switch.emit(_switch_out_battler, battler, _is_instant_switch)
		_switch_out_battler = null
	# TODO: else: show message (switch_in[1])


func _on_battler_ready(battler: Battler) -> void:
	_switch_out_battler = battler # Current battler selecting action, which could be to switch out
