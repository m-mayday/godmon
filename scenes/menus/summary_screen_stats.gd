extends Control

var _visible_scroll: bool = false ## If the ability description is too long and has a scroll


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
	$Stats/HP/HpProgressBar.set_hp_bar_progress(pokemon.current_hp, pokemon.stats.hp)
