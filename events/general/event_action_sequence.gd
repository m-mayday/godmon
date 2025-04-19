class_name EventActionSequence
extends EventAction
## A sequence of [code]EventActions[/code].
## Useful to save and reuse a sequence of actions as a resource.

@export var event_actions: Array[EventAction] ## The sequence of [code]EventAction[/code].

## Executes each action in [code]event_actions[/code].
func execute(node: Node) -> bool:
	for action in event_actions:
		var executed: bool = await action.execute(node)
		if not executed:
			return executed
	return true
