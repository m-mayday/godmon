extends CanvasLayer

@export var save_slot_template: Container
@export var options_container: VBoxContainer
@export var new_game_option: Button

func _ready() -> void:
	var save_files: Array[SaveData] = Global.get_save_files()
	if len(save_files) > 0:
		for child in options_container.get_children():
			options_container.remove_child(child)
		for i in save_files.size():
			var template: Container = save_slot_template.duplicate()
			var slot: Button = template.get_node("SaveSlot")
			slot.with_data(save_files[i])
			slot.focus_entered.connect(_on_save_slot_focus_entered.bind(i))
			slot.focus_exited.connect(_on_save_slot_focus_exited.bind(i))
			slot.pressed.connect(_on_save_slot_pressed.bind(i))
			options_container.add_child(template)
		options_container.add_child(new_game_option)
	save_slot_template.queue_free()
	var first_option = options_container.get_child(0)
	if first_option is Button:
		first_option.grab_focus()
	else:
		first_option.get_node("SaveSlot").grab_focus()


func _on_save_slot_focus_entered(index: int) -> void:
	var container: Container = options_container.get_child(index)
	container.get_node("Label").show()


func _on_save_slot_focus_exited(index: int) -> void:
	var container: Container = options_container.get_child(index)
	container.get_node("Label").hide()
	
	
func _on_save_slot_pressed(index: int) -> void:
	Global.game_data.load_game(index, get_tree())
	queue_free()


func _on_new_game_pressed() -> void:
	var main = get_tree().root.get_node("Main")
	main.play_intro()
	queue_free()
