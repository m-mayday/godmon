class_name MovementSequenceAction
extends EventAction
## A sequence of [code]MovementActions[/code].
## Useful to run a sequence of actions in parallel with another node using [code]ParallelActions[/code].

@export var movement_actions: Array[MovementAction] ## The sequence of [code]MovementAction[/code].

## Executes each action in [code]movement_actions[/code].
func execute(node: Node) -> bool:
	for action in movement_actions:
		var executed: bool = await action.execute(node)
		if not executed:
			return executed
	return true
