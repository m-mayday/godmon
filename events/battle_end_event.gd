class_name BattleEndEvent
extends BaseEvent
## Used when a Pokemon levels up

var won: bool
var escaped: bool

func _init(p_won: bool, p_escaped: bool):
	won = p_won
	escaped = p_escaped


func _to_string():
	return "Battle End Event"
