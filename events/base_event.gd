class_name BaseEvent
extends Resource
## Base class for events in game
## It consists of signals to await for and a time to wait after action is executed


var await_signals: Array[Signal] ## An array of signals to await for after action is executed
var post_await: float = 0.0 ## Amount to wait after action is called and signals are awaited


func _to_string():
	return "Base Event"
