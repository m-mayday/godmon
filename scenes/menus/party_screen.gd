extends CanvasLayer

## Emitted when the screen is closed
signal screen_closed

## Emitted when a battler has been chosen to be switched in
signal switch(switch_out: Battler, switch_in: Battler, is_instant_switch: bool) 

## Context for this screen. Available options may change according to this context
enum CONTEXT {
	OVERWORLD,
	BATTLE,
}

@export var context: CONTEXT = CONTEXT.OVERWORLD
@export var slots_container: Node ## The Pokemon slots container
@export var slot_options: VBoxContainer ## The options available for a slot
@export var cancel_button: TextureButton ## Cancel button to close the screen
@export var context_exclusive_options: Dictionary[CONTEXT, Array] ## Options only available per context. Array type should be NodePath
@export var summary_screen: CanvasLayer


var _cancel_texture: Texture2D ## Normal cancel texture to change on focus. This is because the normal texture "spills" under the focued one
var _current_slot_normal_texture: Texture2D ## Current slot's normal texture, to return it to normal when a slot is a selected and it must appear "focused"
var _selected_slot_index: int ## The selected Pokemon slot index
var _switch_out_battler: Battler ## Battler that is switching out
var _is_instant_switch: bool ## If an instant switch has been requested


func _ready() -> void:
	_cancel_texture = cancel_button.texture_normal
	_set_up_slots()
	if context == CONTEXT.BATTLE:
		SignalBus.battler_ready.connect(_on_battler_ready)
		
	## Set focus neighbors for first and last options to not get focus of the party slots
	var first_option: Button = _get_first_visible_slot_option()
	var last_option: Button = slot_options.get_child(slot_options.get_child_count()-1) as Button
	last_option.focus_neighbor_bottom = first_option.get_path()
	first_option.focus_neighbor_top = last_option.get_path()


func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("cancel") or event.is_action_pressed("ui_cancel"):
			if summary_screen.visible:
				summary_screen.hide()
				_grab_slot_option_focus(_get_first_visible_slot_option())
				return
			elif %SlotOptions.visible:
				_on_slot_cancel_pressed()
				return
			screen_closed.emit()


## A battler needs to be switched in, so show the menu
func request_switch(event: RequestSwitchEvent):
	show()
	_switch_out_battler = event.battler
	_is_instant_switch = event.is_instant_switch


## Called when part of the 'summary' group, if the current Pokemon changes while in a different screen
func set_pokemon(pokemon: Pokemon) -> void:
	var slot: TextureButton = slots_container.get_child(_selected_slot_index) as TextureButton
	slot.texture_normal = _current_slot_normal_texture
	var index: int = Global.player_party.find(pokemon)
	slot = slots_container.get_child(index) as TextureButton
	_selected_slot_index = index
	_current_slot_normal_texture = slot.texture_normal
	slot.texture_normal = slot.texture_focused


## Prepare the slots to show Pokemon information
func _set_up_slots() -> void:
	var slots: Array[Node] = slots_container.get_children()
	for slot in slots:
		slot.context = context
	
	## Show/Hide context dependent options
	for ctx in context_exclusive_options:
		var options: Array = context_exclusive_options[ctx]
		for option in options:
			var node: Node = get_node(option as NodePath)
			node.visible = ctx == context
			
	slots_container.get_child(0).grab_focus()


## Get the first visible slot option (usually to grab focus)
func _get_first_visible_slot_option() -> Button:
	for option in slot_options.get_children():
		if option.visible:
			return option
	return null


func _grab_slot_option_focus(option: Button) -> void:
	if option != null:
		option.grab_focus()


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
	var slot: TextureButton = slots_container.get_child(index) as TextureButton
	_current_slot_normal_texture = slot.texture_normal
	slot.texture_normal = slot.texture_focused


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


func _on_summary_pressed() -> void:
	summary_screen.set_pokemon_index(_selected_slot_index)
	summary_screen.show()


func _on_battler_ready(battler: Battler) -> void:
	_switch_out_battler = battler # Current battler selecting action, which could be to switch out
