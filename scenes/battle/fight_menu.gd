extends Control
## Menu for a Battler to choose a move in battle

## Emitted when a move has been chosen
signal move_chosen(move: Move)

@export var move_container: GridContainer
@export var pp_amount: Label
@export var move_type: Label


## Moves the battler can choose from
var _moves: Array[Move]

## Remember last selected option to grab focus next time
var _last_selected_by_battler: Dictionary
var _current_battler_id: int 
var _last_selected: int = 0


func _ready():
	SignalBus.battler_ready.connect(_on_battler_ready)


## Grabs focus of the _last_selected option when menu appears on screen
func _on_draw():
	move_container.get_child(_last_selected).grab_focus()


## Remembers the last selected option by this battler if exists, and sets labels to the moves names
func _on_battler_ready(battler: Battler) -> void:
	if not _last_selected_by_battler.has(battler.id):
		_last_selected_by_battler[battler.id] = 0
	_last_selected = _last_selected_by_battler.get(battler.id, 0)
	_current_battler_id = battler.id
	var _move_slots: Array[Node] = move_container.get_children()
	_moves = battler.pokemon.moves
	assert(len(_move_slots) >= len(_moves), "battler has more moves than supported.")
	for i in len(_move_slots):
		var button: Button = _move_slots[i] as Button
		var label: Label = button.get_child(0).get_child(0) as Label
		if i < len(_moves):
			button.disabled = false
			button.focus_mode = Control.FOCUS_ALL
			label.text = _moves[i].name
		else:
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE
			label.text = "-"


## Updates _last_selected option and emites move_chosen signal with the chosen move
func _on_move_pressed(i: int) -> void:
	_last_selected_by_battler[_current_battler_id] = i
	_last_selected = i
	move_chosen.emit(_moves[i])


## Shows the type and PP of the move
func _on_move_focus_entered(i: int):
	var move: Move = _moves[i]
	pp_amount.text = "{0}/{1}".format([move.current_pp, move.base_pp])
	move_type.text = "TYPE/{0}".format([Constants.types[move.type].to_upper()])
