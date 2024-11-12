extends Resource
class_name Stats
## Represents the stats a Pokemon can have

@export_range(0, 255) var hp: int ## Max HP
@export_range(0, 255) var attack: int
@export_range(0, 255) var defense: int
@export_range(0, 255) var speed: int
@export_range(0, 255) var special_attack: int
@export_range(0, 255) var special_defense: int
var accuracy: int ## Pokemon's accuracy in battle only
var evasion: int ## Pokemon's evasion in battle only


func _init(p_hp = 0, p_attack = 0, p_defense = 0, p_speed = 0, p_special_attack = 0, p_special_defense = 0):
	hp = p_hp
	attack = p_attack
	defense = p_defense
	speed = p_speed
	special_attack = p_special_attack
	special_defense = p_special_defense
	accuracy = 100
	evasion = 100
