class_name ReactionAction
extends EventAction


@export var target: EventTargetResolver
@export var animation_name: String = "exclamation"
@export var offset: Vector2 = Vector2(0, -20.0)

var reaction: PackedScene = load("res://scenes/reaction.tscn")

## Node is used to get the node specified as [code]node_path[/code].
func execute(node: Node) -> bool:
	var target_node: Node = target.resolve(node)
	if target_node == null:
		return false
	var reaction_node: AnimatedSprite2D = reaction.instantiate()
	target_node.add_child(reaction_node)
	reaction_node.animation = animation_name
	reaction_node.offset = offset
	reaction_node.show()
	reaction_node.play()
	await reaction_node.animation_finished
	reaction_node.queue_free()
	return true
