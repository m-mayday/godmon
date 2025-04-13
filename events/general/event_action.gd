class_name EventAction
extends Resource
## A base class that represents an executable action.

@export var wait_after: Array[float] ## Time to wait after the action is executed.

func execute(_node: Node):
	pass
