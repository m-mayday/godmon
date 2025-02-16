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


## Applies effects if the node is in a terrain cell
func _on_node_in_cell() -> void:
	if _cell_data != null:
		var data: Variant = _cell_data.get_custom_data("terrain")
		var terrain: String = ""
		if data != null:
			terrain = data as String
		if terrain == "GRASS":
			if grass_overlay_texture != null:
				_grass_overlay_rect = TextureRect.new()
				_grass_overlay_rect.texture = grass_overlay_texture
				_grass_overlay_rect.position = node.position
				node.get_parent().add_child(_grass_overlay_rect)


## Cleans up certain variables when node exits the cell
func _on_node_exit_cell() -> void:
	_node_in_cell = false
	_cell_coordinates = Vector2.ZERO
	_cell_data = null
	if is_instance_valid(_grass_overlay_rect):
		_grass_overlay_rect.queue_free()
