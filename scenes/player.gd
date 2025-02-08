extends Area2D

@export var movement: Node

var _input_direction: Vector2 = Vector2.ZERO ## Direction in which the player will move


func _ready():
	# For testing purposes
	var pokemon_party: Array[Pokemon] = []
	pokemon_party.append(Pokemon.new(Constants.SPECIES.VENUSAUR, 10))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.BULBASAUR, 10))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.BLASTOISE, 10))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.CHARIZARD, 10))
	Global.set_player_party_value(0, pokemon_party[0])
	Global.set_player_party_value(1, pokemon_party[1])
	Global.set_player_party_value(2, pokemon_party[2])
	Global.set_player_party_value(3, pokemon_party[3])
	SignalBus.input_paused.connect(_on_input_paused)
	

func _process(_delta: float) -> void:
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	movement.move(_input_direction)


func _on_input_paused(paused: bool):
	set_process(!paused)
