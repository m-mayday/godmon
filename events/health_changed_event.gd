class_name HealthChangedEvent
extends BaseEvent
## Used when a Pokemon HP changes

var pokemon: Pokemon
var new_hp: int

func _init(p_pokemon: Pokemon, p_new_hp: int):
	pokemon = p_pokemon
	new_hp = p_new_hp


func _to_string():
	return "Health Changed Event"
