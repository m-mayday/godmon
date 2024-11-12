class_name AnimationEvent
extends BaseEvent
## Used when an animation should play

var animation: String ## Name of the animation
var battler: Battler ## Battler that should be animated (could change down the line)
var target: Battler


func _init(animation_name: String, args: Array = []):
	animation = animation_name
	battler = args[0]
	target = args[0]
	if len(args) > 1:
		target = args[1]


func _to_string():
	return "Animation Event"
