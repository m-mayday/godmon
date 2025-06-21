@tool
extends Node

@export var node: Node2D:
	set(v):
		node = v
		_get_configuration_warnings()

@export var grass_overlay_texture: Resource

var _node_in_cell: bool = false ## If node is currently in a cell
var _cell_coordinates: Vector2 = Vector2.ZERO ## The coordinates of the cell the node is in
var _cell_data: TileData = null ## The custom data of the cell the node is in
var _grass_overlay_rect: TextureRect = null ## Grass overlay to add to the node
var _scene_loading: bool = true


func _ready() -> void:
	SignalBus.scene_transition_finished.connect(func(_a, _b): _scene_loading = false, CONNECT_ONE_SHOT)


func _get_configuration_warnings() -> PackedStringArray:
	if node == null:
		return ["TerrainEffects requires 'Node'"]
	return []


## Sets cell_coordinates, cell_data and node_in_cell if the node entered a TileMapLayer cell
func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		var layer: TileMapLayer = body as TileMapLayer
		_cell_coordinates = layer.get_coords_for_body_rid(body_rid)
		_cell_data = layer.get_cell_tile_data(layer.get_coords_for_body_rid(body_rid))
		_node_in_cell = true
		if _scene_loading:
			_enter_tree()
			_scene_loading = false


func _on_movement_finished(previous_state: Constants.MOVEMENT_STATE, _new_state: Constants.MOVEMENT_STATE) -> void:
	if previous_state == Constants.MOVEMENT_STATE.TURNING:
		return
	if previous_state == Constants.MOVEMENT_STATE.JUMPING and _get_terrain() == "":
		_on_jumping_finished()
	else:
		_on_node_in_cell()


func _on_movement_started(_previous_state: Constants.MOVEMENT_STATE, new_state: Constants.MOVEMENT_STATE) -> void:
	if new_state == Constants.MOVEMENT_STATE.TURNING:
		return
	_on_node_exit_cell()


## Applies effects if the node is in a terrain cell
func _on_node_in_cell() -> void:
	var terrain: String = _get_terrain()
	if terrain == "GRASS":
		if grass_overlay_texture != null:
			_add_grass_overlay()
			$EffectAnimation.visible = true
			$EffectAnimation.position = node.global_position
			$EffectAnimation.play("grass")


## Cleans up certain variables when node exits the cell
func _on_node_exit_cell() -> void:
	_node_in_cell = false
	_cell_coordinates = Vector2.ZERO
	_cell_data = null
	if is_instance_valid(_grass_overlay_rect):
		_grass_overlay_rect.queue_free()
		

func _on_effect_animation_animation_finished() -> void:
	$EffectAnimation.visible = false


func _on_jumping_finished() -> void:
	$EffectAnimation.visible = true
	$EffectAnimation.position = get_parent().position
	$EffectAnimation.play("dust")


## Get terrain on [code]_cell_data[/code] if it exists
func _get_terrain() -> String:
	if _cell_data != null:
		var data: Variant = _cell_data.get_custom_data("terrain")
		var terrain: String = ""
		if data != null:
			terrain = data as String
		return terrain
	return ""


## Used when a new scene is loaded
func _enter_tree() -> void:
	if _node_in_cell:
		var terrain: String = _get_terrain()
		if terrain == "GRASS":
			_add_grass_overlay()


func _add_grass_overlay():
	if grass_overlay_texture != null:
		_grass_overlay_rect = TextureRect.new()
		_grass_overlay_rect.texture = grass_overlay_texture
		_grass_overlay_rect.position = node.position
		node.get_parent().call_deferred("add_child", _grass_overlay_rect)
