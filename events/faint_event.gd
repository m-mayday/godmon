extends BaseEvent
class_name FaintEvent
## Used when a battler faints

var battler: Battler ## Battler that fainted

func _init(p_battler: Battler):
	battler = p_battler


func _to_string():
	return "Faint Event"
