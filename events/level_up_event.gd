class_name LevelUpEvent
extends BaseEvent
## Used when a Pokemon levels up

var pokemon: Pokemon
var level: int
var previous_stats: Stats

func _init(p_pokemon: Pokemon, p_level: int, p_previous_stats: Stats):
	pokemon = p_pokemon
	level = p_level
	previous_stats = p_previous_stats


func _to_string():
	return "Level Up Event"
