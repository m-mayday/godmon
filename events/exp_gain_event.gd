class_name ExpGainEvent
extends BaseEvent
## Used when a pokemon gains experience

var pokemon: Pokemon
var exp_gained: int
var levels_gained: int

func _init(p_pokemon: Pokemon, p_exp_gained: int, p_levels_gained: int):
	pokemon = p_pokemon
	exp_gained = p_exp_gained
	levels_gained = p_levels_gained

func _to_string():
	return "Exp Gain Event"
