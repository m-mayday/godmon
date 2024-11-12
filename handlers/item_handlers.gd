class_name ItemHandler
## Base item handler
## Other items override the methods they need
## Methods are roughly ordered the way they happen in battle


static var items: Dictionary = {}


## Returns the handler for the item id provided, or the base item handler if it's not found.
static func get_item_handler(p_item: Item) -> ItemHandler:
	return items.get(p_item.id, ItemHandler.new).call(p_item)


var item: Item


func _init(p_item: Item):
	item = p_item


## Subpriority modifier when calculating priority
func on_priority_bracket_change(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> int:
	return 0


class QuickClaw extends ItemHandler:
	func on_priority_bracket_change(battle: Battle, _user: Battler, _target: Battler, _move: Move) -> int:
		if battle.random(100) < 20: # 20% chance to activate
			return 1
		return 0
