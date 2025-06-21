extends CanvasLayer

signal intro_finished

@export var actions: Array[EventAction] = []
@export var player_male_texture: Texture2D
@export var player_female_texture: Texture2D
@export var default_male_names: Array[String] = ["RED"]
@export var default_female_names: Array[String] = ["LEAF"]
@export var default_rival_name: String = "GREEN"

var gender: Constants.GENDER = Constants.GENDER.MALE
var player_name: String
var rival_name: String
var current_action_index: int = -1
var _player_name_chosen: bool = false

func _ready() -> void:
	await SignalBus.input_paused
	while current_action_index < actions.size() -1:
		current_action_index += 1
		await actions[current_action_index].execute(self)
	Global.game_data.player_name = player_name
	Global.game_data.player_gender = gender
	Global.game_data.rival_name = rival_name
	intro_finished.emit()

func play_animation(p_name: String, marker: String, end: String) -> void:
	$AnimationPlayer.play_section_with_markers(p_name, marker, end)
	await $AnimationPlayer.animation_finished


func show_pokeball() -> void:
	$Pokeball.show()


func set_player_texture(gender: Constants.GENDER) -> void:
	if gender == Constants.GENDER.MALE:
		$Player.texture = player_male_texture
	else:
		$Player.texture = player_female_texture


func _on_name_submitted(text: String) -> void:
	if text == "":
		if not _player_name_chosen:
			if gender == Constants.GENDER.MALE:
				player_name = default_male_names.pick_random()
			else:
				player_name = default_female_names.pick_random()
		else:
			rival_name = default_rival_name
	elif not _player_name_chosen:
		player_name = text
	else:
		rival_name = text


func _grab_line_edit_focus() -> void:
	$LineEdit.text = ""
	$LineEdit.grab_focus()
	await $LineEdit.text_submitted
	$LineEdit.hide()


func input_rival_name() -> void:
	await play_animation("fade_out_rival", "", "")
	$LineEdit.text = ""
	$LineEdit.show()
	$LineEdit.grab_focus()
	await $LineEdit.text_submitted
	$LineEdit.hide()
	await play_animation("fade_in_rival", "", "")
