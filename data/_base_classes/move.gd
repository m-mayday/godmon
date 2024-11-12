class_name Move
extends Resource
## Represents a Pokemon Move

@export var id: Constants.MOVES: set = _set_id_and_move_handler ## The move's id. Also sets the behavior
@export var name: StringName = "Unnamed" ## The move's name to be displayed
@export var type: Constants.TYPES = Constants.TYPES.BUG ## The move's type
@export var category: Constants.MOVE_CATEGORY = Constants.MOVE_CATEGORY.PHYSICAL ## The move's category (Physical/Special)
@export var power: int = 0 ## The move's base power
@export var accuracy: int = 100 ## The move's accuracy
@export var base_pp: int: set = _set_pp_data ## The move's base PP
@export var target: Constants.MOVE_TARGET = Constants.MOVE_TARGET.ALL ## The targets that can be chosen for this move
@export_range(-6, 6, 1) var priority: int = 0 ## The move's priority. Should be between -6 and 6
@export var flags: Array[Constants.MOVE_FLAGS] = [] ## The move's flags (makes contact, sound move, punch move, etc.)
@export_range(0, 100) var effect_chance: int = 0 ## The chance for the move's extra effect to activate (if it has one)
@export var description: String = "???" ## The move's description

var total_pp: int ## The total amount of pp for this move (base_pp * _pp_up_used)
var current_pp: int ## The current amount of pp available to use on this move
var handler: MoveHandler ## The move's behavior in battle

var _pp_up_used: int = 0 ## How many pp_up have been used on this move


## [Private] Called when id is set, loads the correct handler for this move
func _set_id_and_move_handler(value: Constants.MOVES) -> void:
	if id != value:
		id = value
		handler = MoveHandler.get_move_handler(self)


## [Private] Called when base_pp is set, loads the correct values for total_pp and current_pp
func _set_pp_data(value: int) -> void:
	base_pp = value
	total_pp = base_pp
	current_pp = base_pp


## [Public] Indicates if the move is a damaging move (not a status move)
func is_damaging() -> bool:
	return category == Constants.MOVE_CATEGORY.PHYSICAL or category == Constants.MOVE_CATEGORY.SPECIAL


## [Public] Indicates if the move is a physical move
func is_physical() -> bool:
	return category == Constants.MOVE_CATEGORY.PHYSICAL


## [Public] Indicates if the move is a special move
func is_special() -> bool:
	return category == Constants.MOVE_CATEGORY.SPECIAL


## [Public] Indicates if the move is a one hit KO move
func is_ohko() -> bool:
	return power == 0 and is_damaging() and accuracy == 30


## [Public] Deducts PP from move by the amount indicated or 1 by default. If it's not possible to deduct more PP, it returns false
func deduct_pp(pp: int = 1) -> bool:
	if current_pp <= 0:
		return false
	current_pp = maxi(0, current_pp - pp)
	return true
