extends Area2D

@onready var _movement = $GridMovement
@onready var _anim: AnimationTree = $AnimationTree
@onready var _raycast: RayCast2D = $RayCast2D
@onready var _anim_state: AnimationNodeStateMachinePlayback = _anim.get("parameters/playback")


var pokemon_party: Array[Pokemon] = []
var _input_direction: Vector2 = Vector2.ZERO ## Direction in which the player will move


func _ready():
	pokemon_party.append(Pokemon.new(Constants.SPECIES.VENUSAUR, 60))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.BULBASAUR, 60))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.BLASTOISE, 60))
	pokemon_party.append(Pokemon.new(Constants.SPECIES.CHARIZARD, 60))
	Global.set_player_party_value(0, pokemon_party[0])
	Global.set_player_party_value(1, pokemon_party[1])
	Global.set_player_party_value(2, pokemon_party[2])
	Global.set_player_party_value(3, pokemon_party[3])
	

func _process(delta: float) -> void:
	if _input_direction.y == 0:
		_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if _input_direction.x == 0:
		_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	$GridMovement.move(_input_direction)
