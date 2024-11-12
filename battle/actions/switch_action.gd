class_name SwitchAction
extends BaseAction
## Handles the logic of a battler switching out

var switch_out: Battler
var switch_in: Battler
var battle: Battle


func _init(p_switch_out: Battler, p_switch_in: Battler, p_battle: Battle):
	switch_out = p_switch_out
	switch_in = p_switch_in
	battle = p_battle


## [Public] Order of action in relation to others.
func get_action_order() -> int:
	return 2


## [Public] Switching battlers logic
func execute() -> void:
	# TODO: This check might still need to happen
	#if switch_out.side != switch_in.side:
		#print("Not same side: ", switch_out.side, "----", switch_in.side)
		#return
	#battle.run_action_event("before_switch", switch_out, switch_in, [battle, switch_out, switch_in])
	switch_out.side.switch_active_battler(switch_out, switch_in)
	battle.add_battle_event(SwitchEvent.new(switch_out, switch_in))
	switch_out.reset_stat_stages()
	switch_out.battler_flags.clear()
	switch_in.switched_in_this_turn = true
	return
