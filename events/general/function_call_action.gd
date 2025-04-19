class_name FunctionCallAction
extends EventAction
## Action to call a function on a node.

@export var node_path: NodePath ## The path to the node that has the function.
@export var function_name: String ## The name of the function.
@export var arguments: Array[Variant] ## Arguments to pass to the function.
@export var is_player: bool = false ## If the node the function is in is the player.

## Node is used to get the node specified as [code]node_path[/code].
func execute(node: Node) -> bool:
	var node_func: Node
	if is_player:
		node_func = node.get_tree().get_first_node_in_group("player")
	else:
		node_func = node.get_node_or_null(node_path)
	if node_func == null:
		return false
	await node_func.callv(function_name, arguments)
	return true
