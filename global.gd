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


func update_player_party() -> void:
	player_party_changed.emit()


func update_player_battlers() -> void:
	player_side_battlers_changed.emit()
