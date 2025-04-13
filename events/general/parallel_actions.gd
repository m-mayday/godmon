class_name ParallelActions
extends EventAction
## Action to run other [code]EventActions[/code] at the same time.

@export var actions: Array[EventAction] ## The actions to run in parallel.

## Executes all actions in [code]actions[/code] and waits for all of them to finish before returning.
func execute(node: Node) -> bool:
	var tasks: Array[Callable] = []
	for action in actions:
		tasks.append(action.execute.bind(node))
	await Awaiter.all(tasks)
	return true
