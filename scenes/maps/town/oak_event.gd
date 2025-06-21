extends Cutscene

var player: Area2D

@export var actions: Array[EventAction] = []

func _ready() -> void:
	if Global.EVENT_FLAGS["pallet_town_get_starter"] > 0:
		queue_free()

## Execution of the event
func _execute() -> void:
	if player != null and not actions.is_empty():
		for action in actions:
			await action.execute(self)


func _on_area_entered(area: Area2D) -> void:
	player = area
	area.movement_finished.connect(run.unbind(2), CONNECT_ONE_SHOT)
