@tool
extends Area2D

@export var encounter_table: EncounterTable

var _rng: RandomNumberGenerator
var _odds: Array[float]
var _player_in_area: bool = false
var _wild_trainer: Trainer = preload("res://data/trainers/wild.tres")

var player
var current_shape_index: int
var shapes_bounds: Dictionary[int, PackedVector2Array] = {}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	assert(player != null, "Player node must be in scene tree")
	player.movement_finished.connect(_should_trigger_encounter.unbind(2))
	for encounter in encounter_table.encounters:
		_odds.append(encounter.odds)
	for child in get_children():
		if child is CollisionPolygon2D:
			shapes_bounds[child.get_index()] = child.polygon
		elif child is CollisionShape2D and child.shape is RectangleShape2D:
			var shape_size: Vector2 = child.shape.size
			shapes_bounds[child.get_index()] = PackedVector2Array([
				child.position - (shape_size / 2),
				Vector2(child.position.x - shape_size.x/2, child.position.y + shape_size.y/2),
				child.position + (shape_size / 2),
				Vector2(child.position.x + shape_size.x/2, child.position.y - shape_size.y/2),
			])
	_rng = RandomNumberGenerator.new()
	_rng.randomize()


func _on_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	_player_in_area = true
	current_shape_index = shape_find_owner(_local_shape_index)
	

func _on_area_shape_exited(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	_player_in_area = false
	
	
func _should_trigger_encounter() -> void:
	if _player_in_area:
		# Check that the player hasn't left the bounds of the current area
		if not Geometry2D.is_point_in_polygon(to_local(player.position) + Vector2.ONE * (Constants.TILE_SIZE / 2), shapes_bounds[current_shape_index]):
			return
		var number: float = _rng.randf_range(0.0, 2879.0)
		if number < 320.0:
			SignalBus.input_paused.emit(true)
			var encounter: Encounter = encounter_table.encounters[_rng.rand_weighted(_odds)]
			var pokemon1: Pokemon = Pokemon.new(encounter.species, randi_range(encounter.minimum_level, encounter.maximum_level))
			var pokemon2: Pokemon = Pokemon.new(encounter.species, randi_range(encounter.minimum_level, encounter.maximum_level))
			var pokemon3: Pokemon = Pokemon.new(encounter.species, randi_range(encounter.minimum_level, encounter.maximum_level))
			pokemon1.trainer = _wild_trainer
			pokemon2.trainer = _wild_trainer
			pokemon3.trainer = _wild_trainer
			get_tree().root.get_node("Main").load_scene("res://scenes/battle/battle_scene.tscn", false, true, {
				"type": "wild",
				"foe_party": [pokemon1, pokemon2, pokemon3],
			})
			
