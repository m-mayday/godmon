@tool
extends Area2D

@export var encounter_table: EncounterTable
var _odds: Array[float]

var player_in_area: bool = false


func _ready() -> void:
	var player = get_node("../Player")
	assert(player != null, "Player node must be in scene tree")
	player.get_node("GridMovement").movement_finished.connect(_should_trigger_encounter)
	player.get_node("GridMovement").turning_finished.connect(_should_trigger_encounter)
	for encounter in encounter_table.encounters:
		_odds.append(encounter.odds)


func _on_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	player_in_area = true
	

func _on_area_shape_exited(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	player_in_area = false
	
	
func _should_trigger_encounter() -> void:
	if player_in_area:
		var rng = RandomNumberGenerator.new()
		print("Calculate encounter: ", encounter_table.encounters[rng.rand_weighted(_odds)].species)
