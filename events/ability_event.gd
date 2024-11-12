class_name AbilityEvent
extends BaseEvent
## Used when a Pokemon's ability activates in battle

var ability: Ability ## Activated ability
var battler: Battler ## Battler that has the activated ability
var is_ally_side: bool ## If ability activated for ally side or foe side


func _init(ally_side: bool, p_battler: Battler, p_ability: Ability, splash_wait: float = 0.2):
	is_ally_side = ally_side
	battler = p_battler
	ability = p_ability
	post_await = splash_wait


func _to_string():
	return "Ability Event"
