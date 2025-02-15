extends NinePatchRect
## Menu for a Battler to choose a target for its move in battle

signal target_chosen(target, move)

@export var foe_side: HBoxContainer
@export var user_side: HBoxContainer

## Possible targets for the chosen move
var targets: Array[Battler]:
	set(value):
		targets = value
		_on_targets_changed()

## Active battlers on each side
var _user_battlers: Array[Battler]
var _foe_battlers: Array[Battler]

var _move: Move ## Move chosen
var _current_focus: Array = [-1, false] ## Current button in focus. First value is index and second if it's ally side.


func _ready():
	SignalBus.battle_started.connect(_on_battle_started)


## Emits target_chosen signal when move targets multiple battlers, since buttons have no focus in those cases
func _input(event):
	if !visible or len(targets) <= 0:
		return
	if event.is_action_pressed("interact"):
		if _move.target not in [Constants.MOVE_TARGET.SINGLE_ADJACENT, Constants.MOVE_TARGET.SINGLE_ADJACENT_ALLY, Constants.MOVE_TARGET.SINGLE_ADJACENT_FOE, Constants.MOVE_TARGET.SINGLE_ALLY_OR_USER, Constants.MOVE_TARGET.SINGLE_BUT_USER]:
			target_chosen.emit(targets[0], _move)


## Sets the chosen move and updates labels with targets
func on_move_chosen(p_move: Move) -> void:
	_move = p_move
	_on_targets_changed()
	

## Sets the battlers for each side when turn ends
func on_turn_ended(active_user, active_foe) -> void:
	_user_battlers = active_user
	_foe_battlers = active_foe


## Sets the battlers for each side when battle starts
func _on_battle_started(user_active: Array[Battler], _user_team: Array[Battler], foe_active: Array[Battler], _foe_team: Array[Battler], _action: BaseEvent = null) -> void:
	_user_battlers = user_active
	_foe_battlers = foe_active


## Populates labels with targets on each side
func _on_targets_changed() -> void:
	if _move == null:
		return
	var should_allow_focus: bool = _move.target in [Constants.MOVE_TARGET.SINGLE_ADJACENT, Constants.MOVE_TARGET.SINGLE_ADJACENT_ALLY, Constants.MOVE_TARGET.SINGLE_ADJACENT_FOE, Constants.MOVE_TARGET.SINGLE_ALLY_OR_USER, Constants.MOVE_TARGET.SINGLE_BUT_USER]	
	var focused: bool = _populate_labels(false, should_allow_focus)
	_populate_labels(true, should_allow_focus, focused)
	if not should_allow_focus:
		get_tree().call_group("battlers", "on_choosing_targets", targets, _move)


## Sets the labels' text with the targets' names. Sets which target button should be in focus later
func _populate_labels(is_ally_side: bool, should_allow_focus: bool, is_focus_set: bool = false) -> bool:
	var side: HBoxContainer = user_side
	var battlers: Array[Battler] = _user_battlers
	if not is_ally_side:
		side = foe_side
		battlers = _foe_battlers
	for i in battlers.size():
		var slot: Button = side.get_child(i)
		var label: Label = slot.get_child(0).get_child(0)
		label.text = "-"
		slot.focus_mode = FOCUS_NONE
		for target in targets:
			if target.id == battlers[i].id:
				label.text = target.pokemon.name
				if should_allow_focus:
					slot.focus_mode = FOCUS_ALL
					if not is_focus_set:
						is_focus_set = true
						_current_focus = [i, is_ally_side]
	return is_focus_set


## Focuses on label when it's drawn
func _on_label_draw(index: int, is_ally_side: bool) -> void:
	var button: Button
	if is_ally_side:
		if _current_focus[0] == index and _current_focus[1]:
			button = user_side.get_child(index)
	else:
		if _current_focus[0] == index and not _current_focus[1]:
			button = foe_side.get_child(index)
	if button != null and button.focus_mode != FOCUS_NONE:
		button.grab_focus()


## Changes targets to the newly selected one (single target moves) and calls group with the new target
func _on_button_focus_entered(index: int, is_ally_side: bool) -> void:
	var selected_targets: Array[Battler] = [] # Can't pass an array in place for some reason when calling group
	if is_ally_side:
		selected_targets = [_user_battlers[index]]
	else:
		selected_targets = [_foe_battlers[index]]
	get_tree().call_group("battlers", "on_choosing_targets", selected_targets, _move)


## Emits target_chosen signal when a target button is pressed
func _on_battler_pressed(index: int, is_ally: bool) -> void:
	if is_ally:
		target_chosen.emit(_user_battlers[index], _move)
	else:
		target_chosen.emit(_foe_battlers[index], _move)
