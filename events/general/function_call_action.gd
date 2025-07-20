class_name FunctionCallAction
extends EventAction
## Action to call a function on a node.

@export var target: EventTargetResolver
@export var function_name: String ## The name of the function.
@export var arguments: Array[Variant] ## Arguments to pass to the function.

## Node is used to get the node specified as [code]node_path[/code].
func execute(node: Node) -> bool:
	var target_node: Node = target.resolve(node)
	if target_node == null:
		return false
	target.resolve_node_path_arguments(node, arguments)
	await target_node.callv(function_name, arguments)
	return true
