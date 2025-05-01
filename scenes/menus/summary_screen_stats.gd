extends Control

var _visible_scroll: bool = false ## If the ability description is too long and has a scroll
var _hp_progress_color: Array[Color] = [Color("70f8a8"), Color("f8e038"), Color("f85838")] ## HP bar colors


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _visible_scroll:
		return
	
	## If the ability description is too long, scroll it instead of changing Pokemon (Summary Screen)
	if event.is_action_pressed("ui_down", true):
		$Description/RichTextLabel.get_v_scroll_bar().value += 5
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up", true):
		$Description/RichTextLabel.get_v_scroll_bar().value -= 5
		get_viewport().set_input_as_handled()


func set_pokemon(pokemon) -> void:
	_update_info(pokemon)


func _update_info(pokemon: Pokemon) -> void:
	$Stats/HP.text = "{0}/{1}".format([pokemon.current_hp, pokemon.stats.hp])
	$Stats/Attack.text = str(pokemon.stats.attack)
	$Stats/Defense.text = str(pokemon.stats.defense)
	$Stats/SpAttack.text = str(pokemon.stats.special_attack)
	$Stats/SpDefense.text = str(pokemon.stats.special_defense)
	$Stats/Speed.text = str(pokemon.stats.speed)
	$Ability2/Label.text = pokemon.ability.name
	$Description/RichTextLabel.text = pokemon.ability.description
	_visible_scroll = $Description/RichTextLabel.get_v_scroll_bar().visible
	$Stats/HP/TextureProgressBar.max_value = pokemon.stats.hp
	var hp_percentage := float(pokemon.current_hp) / float(pokemon.stats.hp)
	if hp_percentage > 0.5:
		$Stats/HP/TextureProgressBar.tint_progress = _hp_progress_color[0]
	elif hp_percentage > 0.2 && hp_percentage <= 0.5:
		$Stats/HP/TextureProgressBar.tint_progress = _hp_progress_color[1]
	else:
		$Stats/HP/TextureProgressBar.tint_progress = _hp_progress_color[2]
	$Stats/HP/TextureProgressBar.value = pokemon.current_hp
