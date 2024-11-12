extends Node

@export var allies: Node
@export var opponents: Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_animation(event: AnimationEvent) -> void:
	var userNode: Node
	var targetNode: Node
	if allies != null:
		for ally in allies.get_children():
			if ally.is_in_group("battlers") and ally.battler.id == event.battler.id:
				userNode = ally
			if ally.is_in_group("battlers") and ally.battler.id == event.target.id:
				targetNode = ally
	if opponents != null:
		for opponent in opponents.get_children():
			if opponent.is_in_group("battlers") and opponent.battler.id == event.target.id:
				targetNode = opponent
			if opponent.is_in_group("battlers") and opponent.battler.id == event.battler.id:
				userNode = opponent
	if userNode != null and targetNode != null:
		var original_animation: Animation = animation_player.get_animation(event.animation)
		if original_animation == null:
			return
		
		var animation_library: AnimationLibrary = animation_player.get_animation_library(animation_player.get_animation_library_list()[0]) 
		var animation: Animation = original_animation.duplicate()
		animation_library.add_animation("temp", animation)
		
		var user_track_idxs: Array[int] = []
		var user_track_properties: Array[StringName] = []
		var target_track_idxs: Array[int] = []
		var target_track_properties: Array[StringName] = []
		var track_count: int = animation.get_track_count()
		for i in range(track_count):
			var path: NodePath = animation.track_get_path(i)
			if "DummyOpponent" in str(path):
				target_track_idxs.append(i)
				target_track_properties.append(":" + path.get_concatenated_subnames())
			elif "DummyAlly" in str(path):
				user_track_idxs.append(i)
				user_track_properties.append(":" + path.get_concatenated_subnames())
		for i in range(user_track_idxs.size()):
			animation.track_set_path(user_track_idxs[i], NodePath(str(userNode.get_path()) + user_track_properties[i]))
		for i in range(target_track_idxs.size()):
			animation.track_set_path(target_track_idxs[i], NodePath(str(targetNode.get_path()) + target_track_properties[i]))
			$AnimatedSprite2D.position = targetNode.get_global_position()
		animation_player.play("temp")
		await animation_player.animation_finished
		animation_player.stop() # Needed for a bug that crashes the game when adding/removing animations
		animation_library.remove_animation("temp")
