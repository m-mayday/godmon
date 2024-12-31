extends TextureButton

var pokemon: Pokemon:
	set(v):
		pokemon = v
		_on_pokemon_changed()

var normal_texture: Texture2D


func _ready() -> void:
	normal_texture = texture_normal


func _on_focus_entered() -> void:
	texture_normal = texture_focused


func _on_focus_exited() -> void:
	texture_normal = normal_texture


func _on_pokemon_changed() -> void:
	$HBoxContainer/Lv.text = str(pokemon.level)
	$Name.text = pokemon.name
	$HP.text = "{0} / {1}".format([pokemon.current_hp, pokemon.stats.hp])
