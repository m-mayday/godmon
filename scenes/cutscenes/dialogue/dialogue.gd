extends Interaction

@export var dialogue: DialogueResource ## Dialogue to display
@export var balloon: PackedScene

func _execute() -> void:
	if dialogue != null:
		DialogueManager.show_dialogue_balloon_scene(balloon, dialogue, "start")
		await DialogueManager.dialogue_ended
		await get_tree().create_timer(0.1).timeout ## Wait for a bit so dialogue doesn't start again on its own (same interaction button)
