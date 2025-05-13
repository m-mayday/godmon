extends Cutscene

@export var actions: Array[EventAction]

func _ready() -> void:
	var event_flag: int = Global.EVENT_FLAGS["pallet_town_get_starter"]
	if event_flag == 0:
		$"../Professor".hide()
		$"../Rival".hide()
	elif event_flag == 1:
		await SignalBus.scene_transition_finished
		await run()

## Execution of the event
func _execute() -> void:
	for action in actions:
		await action.execute(self)
