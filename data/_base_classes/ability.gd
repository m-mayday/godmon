class_name Ability
extends Resource
## Represents a Pokemon's ability

@export var id: Constants.ABILITIES: set = _set_id_and_ability_handler ## Ability id
@export var name: String ## Ability name to be displayed
@export var description: String ## A description of this ability
@export var flags: Array[Constants.ABILITY_FLAGS] ## The ability's flags (breakable, no transform, etc.)

var handler: AbilityHandler ## The ability's behavior in battle


## [Private] Called when id is set, loads the correct handler for this ability
func _set_id_and_ability_handler(value: Constants.ABILITIES) -> void:
	id = value
	handler = AbilityHandler.get_ability_handler(self)
