extends CanvasLayer

signal screen_closed

@export var select_slot_message: DialogueResource
@export var overwrite_file_message: DialogueResource
@export var saving_game_message: DialogueResource
@export var game_saved_message: DialogueResource
@export var slots_container: VBoxContainer
@export var balloon: CanvasLayer

var _save_files: Array[SaveData] = []
var _selected_slot_index: int = 0
var _overwriting_file: bool = false
var _normal_stylebox: StyleBox
var _focus_stylebox: StyleBox


func _ready() -> void:
	var slot: Button = slots_container.get_child(0)
	_normal_stylebox = slot.get_theme_stylebox("normal")
	_focus_stylebox = slot.get_theme_stylebox("focus")
	select_slot()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and not _overwriting_file:
		screen_closed.emit()


func _on_save_slot_pressed(index: int) -> void:
	_selected_slot_index = index
	if len(_save_files) -1 >= index:
		_overwriting_file = true
		balloon.start(overwrite_file_message, "start", [self])
		var slot: Button = slots_container.get_child(index)
		slot.add_theme_stylebox_override("normal", _focus_stylebox)
	else:
		save_game()


## Shows the select_slot message and grabs focus of a save slot
func select_slot() -> void:
	_overwriting_file = false
	balloon.start(select_slot_message, "start")
	_populate_save_slots()
	await balloon.dialogue_label.finished_typing
	var selected_slot: Button = slots_container.get_child(_selected_slot_index)
	selected_slot.add_theme_stylebox_override("normal", _normal_stylebox)
	selected_slot.grab_focus()


func save_game() -> void:
	SignalBus.input_paused.emit(true)
	balloon.start(saving_game_message, "start")
	await balloon.dialogue_label.finished_typing
	var slot_index: int = _selected_slot_index
	if _selected_slot_index > len(_save_files)-1:
		slot_index = maxi(0, len(_save_files))
	if Global.save_game(slot_index):
		_populate_save_slots()
		balloon.start(game_saved_message, "start")
		await balloon.dialogue_label.finished_typing
		await get_tree().create_timer(0.2).timeout
		SignalBus.input_paused.emit(false)
		screen_closed.emit()
	# What to do if saving failed?


## Passes save data to save slots.
func _populate_save_slots() -> void:
	_save_files = Global.get_save_files()
	for i in slots_container.get_child_count():
		var save_file: SaveData = null
		if len(_save_files) - 1 >= i:
			save_file = _save_files[i]
		slots_container.get_child(i).with_data(save_file)
