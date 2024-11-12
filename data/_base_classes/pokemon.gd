extends Resource
class_name Pokemon
## Represents a concrete Pokemon

# TODO: Refactor some of this methods. Some stuff will remain undocumented until then

@export var species: Species ## Holds info about this Pokemon species
@export var name: StringName = "Unnamed" ## This Pokemon name
@export var level: int ## This Pokemon level
@export var experience: int ## This Pokemon current experience
@export var current_hp: int ## This Pokemon current HP
@export var stats: Stats ## This Pokemon current stats
@export var ivs: Stats ## This Pokemon IVs
@export var evs: Stats ## This Pokemon EVs
@export var moves: Array[Move] = [] ## This Pokemon current moveset
@export var ability: Ability ## This Pokemon ability
@export var item: Item ## This Pokemon held item
@export var status: Status ## This Pokemon current status
@export var happiness: int = 0 ## This Pokemon current happiness
@export_range(0, 4294967295) var personal_id: int ## This Pokemon personal ID
var id: int ## Internal id used for battles


func _init(species_id: Constants.SPECIES = Constants.SPECIES.BULBASAUR, initial_level: int = 5):
	species = Constants.get_species_by_id(species_id)
	name = species.name
	happiness = species.happiness
	stats = Stats.new()
	ivs = Stats.new()
	evs = Stats.new()
	status = Constants.get_status_by_id(Constants.STATUSES.NONE)
	ability = Constants.get_ability_by_id(Constants.ABILITIES.STENCH)
	item = Constants.get_item_by_id(Constants.ITEMS.QUICK_CLAW)
	current_hp = 1
	personal_id = randi_range(0, pow(2, 16)) | (randi_range(0, pow(2, 16)) << 16)
	level = initial_level
	id = get_instance_id()
	moves = []
	_calculate_stats()


## [Private] Calculates the stats this Pokemon should have, based on level, IVs and EVs
func _calculate_stats():
	stats.hp = _calculate_HP(species.base_stats.hp, level, ivs.hp, evs.hp)
	stats.attack = _calculate_single_stat(species.base_stats.attack, level, ivs.attack, evs.attack, 100)
	stats.defense = _calculate_single_stat(species.base_stats.defense, level, ivs.defense, evs.defense, 100)
	stats.speed = _calculate_single_stat(species.base_stats.speed, level, ivs.speed, evs.speed, 100)
	stats.special_attack = _calculate_single_stat(species.base_stats.special_attack, level, ivs.special_attack, evs.special_attack, 100)
	stats.special_defense = _calculate_single_stat(species.base_stats.special_defense, level, ivs.special_defense, evs.special_defense, 100)
	current_hp = stats.hp


## [Private] Calculates the HP stat based on level, IVs and EVs
func _calculate_HP(base, current_level, iv, ev):
	if base == 1: return 1   # For Shedinja
	return floor((((base * 2) + iv + (ev / 4)) * current_level / 100)) + current_level + 10


## [Private] Calculates a stat based on level, IVs and EVs
func _calculate_single_stat(base, current_level, iv, ev, nature):
	return floor(((floor((((base * 2) + iv + (ev / 4)) * current_level / 100)) + 5) * nature / 100))
