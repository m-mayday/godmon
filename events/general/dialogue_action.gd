class_name DialogueAction
extends EventAction
### Displays the dialogue resource using the provided balloon scene.

@export var dialogue: DialogueResource ## Dialogue to display.
@export var balloon: PackedScene ## Balloon to display the dialogue.
@export var extra_states: Array
@export var title: String = "start"

func execute(node: Node) -> bool:
	if dialogue != null:
		var extra_state_nodes: Array[Node] = []
		for state in extra_states:
			if state is NodePath:
				extra_state_nodes.push_back(node.get_node_or_null(state))
		DialogueManager.show_dialogue_balloon_scene(balloon, dialogue, title, extra_state_nodes)
		await DialogueManager.dialogue_ended
	return true
