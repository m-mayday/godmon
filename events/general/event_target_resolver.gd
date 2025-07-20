class_name EventTargetResolver
extends Resource

enum TARGET_TYPE {
	NODE_PATH,
	PLAYER,
}

@export var target_type: TARGET_TYPE
@export var node_path: NodePath


func resolve(from: Node) -> Node:
	match target_type:
		TARGET_TYPE.NODE_PATH:
			return from.get_node_or_null(node_path)
		TARGET_TYPE.PLAYER:
			return from.get_tree().get_first_node_in_group("player")
	return null


## Convert NodePath arguments to absolute path
func resolve_node_path_arguments(from: Node, arguments: Array[Variant]) -> Array[Variant]:
	for i in arguments.size():
		if arguments[i] is NodePath:
			arguments[i] = from.get_node(arguments[i]).get_path()
	return arguments
