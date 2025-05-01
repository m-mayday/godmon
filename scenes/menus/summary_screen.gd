extends CanvasLayer

@export var button_screens: Dictionary[int, Control] ## Index of Tabs and corresponding sub screen to show
@export var buttons: HBoxContainer ## Container with Tabs (Buttons) as children
@export var title: Label ## The title of the current sub screen
var _pokemon_index: int = -1 ## Pokemon index in the party
var _previous_sub_screen_index: int = -1 ## Previous sub screen index

## Change the current pokemon being displayed
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		set_pokemon_index(wrapi(_pokemon_index + 1, 0, Global.player_party.size()))
	elif event.is_action_pressed("ui_up"):
		set_pokemon_index(wrapi(_pokemon_index - 1, 0, Global.player_party.size()))
		

## Change title and sub screen being displayed, hiding the previous one
func _on_tab_button_focus_entered(index: int) -> void:
	if index == _previous_sub_screen_index:
		return
	if button_screens.has(index):
		var screen: Control = button_screens[index]
		title.text = screen.get_meta("title", "") ## Get title from metadata
		screen.show()
		if button_screens.has(_previous_sub_screen_index):
			button_screens[_previous_sub_screen_index].hide()
			var previous_button: Button = buttons.get_child(_previous_sub_screen_index) as Button
			previous_button.size_flags_horizontal -= 2
		var button: Button = buttons.get_child(index) as Button
		button.size_flags_horizontal += 2
		_previous_sub_screen_index = index


## Set pokemon index to show data and call group "summary" to set their index as well
func set_pokemon_index(index: int) -> void:
	_pokemon_index = index
	_change_data()
	get_tree().call_group("summary", "set_pokemon", Global.player_party[_pokemon_index])


## Display current pokemon data
func _change_data() -> void:
	if _pokemon_index >= 0 and _pokemon_index < Global.player_party.size():
		var pokemon: Pokemon = Global.player_party[_pokemon_index]
		$Control/Name.text = pokemon.name
		$Control/Lv.text = str(pokemon.level)
		$Control/Sprite2D.texture = pokemon.species.front_sprite
		$Control/Sprite2D.scale = pokemon.species.sprite_metrics.front_sprite_scale
		$Control/Status.texture = pokemon.status.icon
		$Control/Status.visible = pokemon.status.icon != null


## Grab focus of first Tab if visible.
## Reset screens when not visible.
func _on_visibility_changed() -> void:
	if visible:
		buttons.get_child(0).grab_focus()
	else:
		if button_screens.has(_previous_sub_screen_index):
			button_screens[_previous_sub_screen_index].hide()
			var previous_button: Button = buttons.get_child(_previous_sub_screen_index) as Button
			previous_button.size_flags_horizontal -= 2
		_previous_sub_screen_index = -1


## Regrabs focus of the last button when interaction with the child screen finishes
func _on_tab_interaction_finished() -> void:
	buttons.get_child(_previous_sub_screen_index).grab_focus()
