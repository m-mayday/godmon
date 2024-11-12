class_name StatusSetEvent
extends BaseEvent
## Used when a Pokemon is afflicted or cured of a status condition.

var pokemon: Pokemon
var status: Status


func _init(p_pokemon: Pokemon, p_status: Status):
	pokemon = p_pokemon
	status = p_status


func _to_string():
	return "Status Set Event"
