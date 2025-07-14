extends Control

signal stats_shown ## Emitted after new stats are shown

@export var stats_container: VBoxContainer
@export var pokemon_sprite: TextureRect
@export var pokemon_name: Label

var stats: Stats ## The new stats
var showed_stats: bool = false ## Flag to know if full stats have been shown (if not, then the stats gained are being shown)


## Display the pokemon's sprite, texture and the stats gained
func on_level_up(event: LevelUpEvent) -> void:
	showed_stats = false
	pokemon_name.text = event.pokemon.name
	pokemon_sprite.texture = event.pokemon.species.front_sprite
	var stat_list: Array[String] = event.previous_stats.get_stat_list()
	for i in range(stat_list.size()):
		var container: HBoxContainer = stats_container.get_child(i) as HBoxContainer
		var value: Label = container.get_child(1) as Label
		value.text = "+ " + str(event.pokemon.stats.get(stat_list[i]) - event.previous_stats.get(stat_list[i]))
		stats = event.pokemon.stats


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact") and not showed_stats:
		var stat_list: Array[String] = stats.get_stat_list()
		for i in range(stat_list.size()):
			var container: HBoxContainer = stats_container.get_child(i) as HBoxContainer
			var value: Label = container.get_child(1) as Label
			value.text = str(stats.get(stat_list[i]))
		showed_stats = true
	elif visible and event.is_action_pressed("interact"):
		showed_stats = false
		stats_shown.emit()
