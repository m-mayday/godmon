class_name BattleStartEvent
extends BaseEvent
## Used when battle starts

var player_side: Side
var opponent_side: Side

func _init(p_player_side: Side, p_opponent_side: Side):
	player_side = p_player_side
	opponent_side = p_opponent_side
	

## [Public] Get the player side's active battlers.
func get_player_side_active() -> Array[Battler]:
	return player_side.active
	

## [Public] Get the player side's team.
func get_player_side_team() -> Array[Battler]:
	return player_side.battlers


## [Public] Get the foe side's active battlers.
func get_opponent_side_active() -> Array[Battler]:
	return opponent_side.active
	

## [Public] Get the foe side's team.
func get_opponent_side_team() -> Array[Battler]:
	return opponent_side.battlers


func _to_string():
	return "Battle Start Event"
