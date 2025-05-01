extends Control


func set_pokemon(pokemon) -> void:
	_update_info(pokemon)


func _update_info(pokemon: Pokemon) -> void:
	$Data/Name.text = pokemon.species.name.to_upper()
	var types: PackedStringArray = []
	for type in pokemon.species.types:
		types.append(type.name.to_upper())
	$Data/Type.text = " / ".join(types)
