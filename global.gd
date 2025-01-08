extends Node

signal player_party_changed
signal player_side_battlers_changed
signal foe_side_battlers_changed


var player_party: Array[Pokemon] = []
var player_side_battlers: Array[Battler] = []
var foe_side_battlers: Array[Battler] = []


func set_player_party_value(index: int, value: Pokemon) -> void:
	if len(player_party) > index:
		player_party[index] = value
	else:
		player_party.append(value)
	player_party_changed.emit()


func get_player_battler(index: int) -> Battler:
	if len(player_side_battlers) > index:
		return player_side_battlers[index]
	return null
	

func get_foe_battler(index: int) -> Battler:
	if len(foe_side_battlers) > index:
		return foe_side_battlers[index]
	return null


func assign_player_battler_array(arr: Array[Battler]) -> void:
	player_side_battlers.assign(arr)
	player_side_battlers_changed.emit()


func assign_foe_battler_array(arr: Array[Battler]) -> void:
	foe_side_battlers.assign(arr)
	foe_side_battlers_changed.emit()


func update_player_party() -> void:
	player_party_changed.emit()


func update_player_battlers() -> void:
	player_side_battlers_changed.emit()
