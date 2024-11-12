class_name BattleDialogueEvent
extends BaseEvent
## Used to display a message in battle

var text: String ## The text to display
var should_wait_input: bool ## Indicates if the message should wait for user input, but it's not enforced


func _init(message: String, args: Array = [], post_wait: float = 0.3, p_should_wait_input: bool = false):
	var final_message: String = message
	if len(args) > 0:
		final_message = message.format(args)
	post_await = post_wait
	should_wait_input = p_should_wait_input
	text = final_message


func _to_string():
	return "Dialogue Event"
