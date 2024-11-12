extends BaseEvent
class_name SwitchEvent
## Used when battlers are switched.

var switch_out: Battler
var switch_in: Battler


func _init(p_switch_out: Battler, p_switch_in: Battler):
	switch_out = p_switch_out
	switch_in = p_switch_in


func _to_string():
	return "Switch Event"
