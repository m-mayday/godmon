class_name Status
extends Resource
## Represents a non-volatile status (Poison, Burn, Sleep, etc.)

@export var id: Constants.STATUSES: set = _set_id_and_status_handler ## Status id
@export var name: String ## Status name to be displayed
@export var immune_types: Array[Constants.TYPES] ## Types that are immune to this status
@export var icon: Texture2D ## The status's icon to display
var handler: StatusHandler ## The status's behavior in battle

## [Private] Called when id is set, loads the correct handler for this status
func _set_id_and_status_handler(value: Constants.STATUSES) -> void:
	if id != value:
		id = value
		handler = StatusHandler.get_status_handler(self)
