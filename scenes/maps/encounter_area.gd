@tool
extends Area2D

@export var encounter_table: EncounterTable

var _rng: RandomNumberGenerator
var _odds: Array[float]
var _player_in_area: bool = false


func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	assert(player != null, "Player node must be in scene tree")
	player.get_node("GridMovement").movement_finished.connect(_should_trigger_encounter.unbind(2))
	for encounter in encounter_table.encounters:
		_odds.append(encounter.odds)
	_rng = RandomNumberGenerator.new()
	_rng.randomize()


func _on_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	_player_in_area = true
	

func _on_area_shape_exited(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	_player_in_area = false
	
	
func _should_trigger_encounter() -> void:
	if _player_in_area:
		var number: float = _rng.randf_range(0.0, 2879.0)
		if number < 320.0:
			var encounter: Encounter = encounter_table.encounters[_rng.rand_weighted(_odds)]
			var pokemon1: Pokemon = Pokemon.new(encounter.species, randi_range(encounter.minimum_level, encounter.maximum_level))
			var pokemon2: Pokemon = Pokemon.new(encounter.species, randi_range(encounter.minimum_level, encounter.maximum_level))
			var pokemon3: Pokemon = Pokemon.new(encounter.species, randi_range(encounter.minimum_level, encounter.maximum_level))
			get_tree().root.get_node("Main").load_scene("res://scenes/battle/battle_scene.tscn", false, true, ["wild", get_tree().get_first_node_in_group("player"), [pokemon1, pokemon2, pokemon3]])
			
