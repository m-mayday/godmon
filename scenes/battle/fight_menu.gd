extends Control
## Menu for a Battler to choose a move in battle

## Emitted when a move has been chosen
signal move_chosen(move: Move)

## Moves the battler can choose from
var _moves: Array[Move]

## Remember last selected option to grab focus next time
var _last_selected_by_battler: Dictionary
var _current_battler_id: int 
var _last_selected: int = 0

@onready var _move_container: GridContainer = $HBoxContainer/Moves/MarginContainer/GridContainer
@onready var _pp_amount: Label = $HBoxContainer/MoveInfo/MarginContainer/VBoxContainer/HBoxContainer/PPAmountLabel
@onready var _move_type: Label = $HBoxContainer/MoveInfo/MarginContainer/VBoxContainer/MoveTypeLabel


func _ready():
	SignalBus.battler_ready.connect(_on_battler_ready)


## Grabs focus of the _last_selected option when menu appears on screen
func _on_draw():
	_move_container.get_child(_last_selected).grab_focus()


## Remembers the last selected option by this battler if exists, and sets labels to the moves names
func _on_battler_ready(battler: Battler) -> void:
	if not _last_selected_by_battler.has(battler.id):
		_last_selected_by_battler[battler.id] = 0
	_last_selected = _last_selected_by_battler.get(battler.id, 0)
	_current_battler_id = battler.id
	var _move_slots: Array[Node] = _move_container.get_children()
	_moves = battler.pokemon.moves
	for i in len(_moves):
		var label = _move_slots[i].get_child(0).get_child(0) as Label
		label.text = _moves[i].name


## Updates _last_selected option and emites move_chosen signal with the chosen move
func _on_move_pressed(i: int) -> void:
	_last_selected_by_battler[_current_battler_id] = i
	_last_selected = i
	move_chosen.emit(_moves[i])


func _on_move_focus_entered(i: int):
	var move: Move = _moves[i]
	_pp_amount.text = "{0}/{1}".format([move.current_pp, move.base_pp])
	_move_type.text = "TYPE/{0}".format([Constants.types[move.type].to_upper()])
