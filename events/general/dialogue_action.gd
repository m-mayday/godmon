class_name DialogueAction
extends EventAction
### Displays the dialogue resource using the provided balloon scene.

@export var dialogue: DialogueResource ## Dialogue to display.
@export var balloon: PackedScene ## Balloon to display the dialogue.

func execute(_node: Node) -> void:
	if dialogue != null:
		DialogueManager.show_dialogue_balloon_scene(balloon, dialogue, "start")
		await DialogueManager.dialogue_ended
