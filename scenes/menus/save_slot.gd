extends Button

@export var label_container: Control
@export var player_name: Label
@export var play_time: Label
@export var empty_label: Label


func with_data(save_data: SaveData) -> void:
	if save_data == null:
		empty_label.show()
		_change_labels_visiblity(false)
	else:
		_change_labels_visiblity(true)
		player_name.text = save_data.player_name
		play_time.text = "TIME: " + Global.get_play_time_string(save_data.play_time)
		empty_label.hide()


func _change_labels_visiblity(p_visible: bool) -> void:
	for label in label_container.get_children():
		if label != empty_label:
			label.visible = p_visible
