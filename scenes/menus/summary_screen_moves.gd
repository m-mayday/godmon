extends Control

signal interaction_finished ## When interaction on this screen (checking moves) is done

@export var moves: Control ## Control containing the move buttons
@export var category_icons: Dictionary[Constants.MOVE_CATEGORY, Texture2D] ## Move category icons
var _pokemon: Pokemon ## Current pokemon


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") and not $Details.visible:
		moves.get_child(0).grab_focus()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("interact") and $Cancel.has_focus():
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cancel") and $Details.visible:
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()


func set_pokemon(pokemon: Pokemon) -> void:
	_pokemon = pokemon
	_update_info()


func _update_info() -> void:
	for i in moves.get_child_count():
		var button: Button = moves.get_child(i)
		if i < len(_pokemon.moves):
			button.get_node("Type").text = Constants.TYPES.keys()[_pokemon.moves[i].type]
			button.get_node("Move").text = _pokemon.moves[i].name.to_upper()
			button.get_node("PP").text = "PP {0}/{1}".format([_pokemon.moves[i].current_pp, _pokemon.moves[i].total_pp])
			button.show()
		else:
			button.hide()


## Display the move's information
func _on_move_focus_entered(index: int) -> void:
	var move: Move = _pokemon.moves[index]
	var types: PackedStringArray = []
	for type in _pokemon.species.types:
		types.append(type.name.to_upper())
	$Details/Type.text = " / ".join(types)
	$Details/CategoryIcon.texture = category_icons[move.category]
	if move.power == 0:
		$Details/Power.text = "-"
	else:
		$Details/Power.text = str(move.power)
	if move.accuracy == 0:
		$Details/Accuracy.text = "-"
	else:
		$Details/Accuracy.text = str(move.accuracy)
	$Cancel.show()
	$Details.show()


func _on_cancel_pressed() -> void:
	$Details.hide()
	$Cancel.hide()
	interaction_finished.emit()


## Reset move information when cancel button is focused
func _on_cancel_focus_entered() -> void:
	$Details.show()
	$Cancel.show()
	$Details/CategoryIcon.texture = null
	$Details/Power.text = ""
	$Details/Accuracy.text = ""
	$Details/Description/RichTextLabel.text = ""


func _on_move_focus_exited() -> void:
	$Details.hide()
	$Cancel.hide()
