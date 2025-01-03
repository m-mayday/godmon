extends TextureButton

enum CONTEXT {OVERWORLD, BATTLE}

@export var context: CONTEXT = CONTEXT.OVERWORLD
@export var level_label: Label
@export var name_label: Label
@export var hp_label: Label

var _has_data: bool = false # If there's a Pokemon to show data of
var _normal_texture: Texture2D


func _ready() -> void:
	_normal_texture = texture_normal
	Global.player_party_changed.connect(_on_pokemon_changed)
	Global.player_side_battlers_changed.connect(_on_pokemon_changed)
	_on_pokemon_changed() # In case the initial signal is missed
 	# One time thing in case the parent is intantiated and added to the tree dynamically, not triggering the visiblity signal
	if owner.visible and _has_data:
		show()


func _on_focus_entered() -> void:
	texture_normal = texture_focused
	

func _on_focus_exited() -> void:
	texture_normal = _normal_texture


func _on_pokemon_changed() -> void:
	var pokemon: Pokemon
	var index: int = get_index()
	if context == CONTEXT.OVERWORLD and len(Global.player_party) > index:
		pokemon = Global.player_party[index]
	elif context == CONTEXT.BATTLE and len(Global.player_side_battlers) > index:
		pokemon = Global.player_side_battlers[index].pokemon
	if pokemon != null:
		level_label.text = str(pokemon.level)
		name_label.text = pokemon.name
		hp_label.text = "{0} / {1}".format([pokemon.current_hp, pokemon.stats.hp])
		_has_data = true
	else:
		_has_data = false


func _on_parent_visibility_changed() -> void:
	if not visible and _has_data:
		show()
	else:
		hide()
