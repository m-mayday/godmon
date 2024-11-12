class_name Item
extends Resource
## Represents an item the player or Pokemon can use

@export var id: Constants.ITEMS: set = _set_id_and_item_handler ## Item id
@export var name: String ## Item name to be displayed
@export var description: String ## A description of this item

var handler: ItemHandler ## The item's behavior in battle


## [Private] Called when id is set, loads the correct handler for this item
func _set_id_and_item_handler(value: Constants.ITEMS) -> void:
	id = value
	handler = ItemHandler.get_item_handler(self)
