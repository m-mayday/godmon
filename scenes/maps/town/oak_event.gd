extends Cutscene

var player: Area2D

func _ready() -> void:
	$"../PlayerPath".hide()
	$"../OakPath".hide()


## Execution of the event
func _execute() -> void:
	if player != null:
		var resource: DialogueResource = DialogueManager.create_resource_from_text("~ start\nOAK: Hey! Wait!\\nDon't go out![next=0.4]\n=> END")
		var points: PackedVector2Array = $"../PlayerPath".points
		var oak_points: PackedVector2Array = $"../OakPath".points
		var npc: Sprite2D = $"../NPC"
		npc.position = $"../OakPath".get_point_position(0)
		npc.position.y += Constants.TILE_SIZE
		DialogueManager.show_dialogue_balloon_scene("res://scenes/cutscenes/dialogue/balloon.tscn", resource)
		await DialogueManager.dialogue_ended
		await player.cutscene_move(player.position, 1, Vector2.DOWN)
		
		for i in oak_points.size():
			var target_position: Vector2 = $"../OakPath".get_point_position(i).snapped(Vector2.ONE * Constants.TILE_SIZE)
			var tiles: Vector2 = abs(npc.position-target_position) / Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
			var speed: float = maxf(tiles.x, tiles.y)
			await npc.cutscene_move(target_position, speed, (npc.position - target_position).normalized() * -1)
		
		resource = DialogueManager.create_resource_from_text("~ start\nOAK: It's unsafe!\\nWild POKéMON live in tall grass![icon]\nYou need your own POKéMON for\\nyour protection.[icon]\nI know!\\nHere, come with me!\n=> END")
		DialogueManager.show_dialogue_balloon_scene("res://scenes/cutscenes/dialogue/balloon.tscn", resource)
		await DialogueManager.dialogue_ended
		for i in points.size()-1:
			var target_position: Vector2 = $"../PlayerPath".get_point_position(i).snapped(Vector2.ONE * Constants.TILE_SIZE)
			var npc_target_position: Vector2 = $"../PlayerPath".get_point_position(i+1).snapped(Vector2.ONE * Constants.TILE_SIZE)
			var tiles: Vector2 = abs(player.position-target_position) / Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
			var npc_tiles: Vector2 = abs(npc.position-npc_target_position) / Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
			var speed: float = maxf(tiles.x, tiles.y)
			npc.cutscene_move(npc_target_position, maxf(npc_tiles.x, npc_tiles.y), (npc.position - npc_target_position).normalized() * -1)
			await player.cutscene_move(target_position, speed, (player.position - target_position).normalized() * -1)
		
		npc.cutscene_move(npc.position, 1.0, Vector2.UP)
		await $"../OaksDoor".open_door()
		await npc.cutscene_move(npc.position + Vector2(0, -Constants.TILE_SIZE), 1.0, Vector2.UP)
		npc.visible = false
		await player.cutscene_move(player.position + Vector2(Constants.TILE_SIZE, 0), 1.0, Vector2.RIGHT)
		await player.cutscene_move(player.position + Vector2(0, -Constants.TILE_SIZE), 1.0, Vector2.UP)
		player.visible = false
		await $"../OaksDoor".close_door()
		$"../OaksDoor".load_target_scene()
		player = null


func _on_area_entered(area: Area2D) -> void:
	player = area
	area.movement_finished.connect(run.unbind(2), CONNECT_ONE_SHOT)
