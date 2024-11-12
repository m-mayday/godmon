class_name RequestSwitchEvent
extends BaseEvent
## Used to request a switch from the user in battle

var battler: Battler ## The battler that will switch out.
var is_instant_switch: bool ## If the switch should happen immediately.


func _init(battle: Battle, p_battler: Battler, p_is_instant_switch: bool = false):
	await_signals.push_back(battle.action_chosen)
	battler = p_battler
	is_instant_switch = p_is_instant_switch


func _to_string():
	return "Request Switch Event"
