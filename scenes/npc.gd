extends Sprite2D

const ANIMATION_PARAMETERS: Dictionary[String, String] = {
	"idle": "parameters/idle/blend_position",
	"walk": "parameters/walk/blend_position",
}

@export var animation_tree: AnimationTree

var interactable: bool = false ## If the NPC can be interacted with
var face_direction: Vector2 = Vector2.DOWN ## Current player direction

var _anim_state: AnimationNodeStateMachinePlayback

func _ready() -> void:
	SignalBus.input_paused.connect(_on_interaction)
	_anim_state = animation_tree.get("parameters/playback")


## Set the NPC as interactable when the InteractionFinder enters it
func _on_area_2d_area_entered(_area: Area2D) -> void:
	interactable = true
	

## Set the NPC as not interactable when the InteractionFinder exits it
func _on_area_2d_area_exited(_area: Area2D) -> void:
	interactable = false


## Make the NPC look at the player
func _on_interaction(_paused: bool) -> void:
	if interactable:
		var player: Node = get_tree().get_first_node_in_group("player")
		var player_direction: Vector2 = player.face_direction
		var npc_direction: Vector2 = Vector2.DOWN
		if player_direction == Vector2.DOWN:
			npc_direction = Vector2.UP
		elif player_direction == Vector2.RIGHT:
			npc_direction = Vector2.LEFT
		elif player_direction == Vector2.LEFT:
			npc_direction = Vector2.RIGHT
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], npc_direction)
		_anim_state.travel("idle")


## Used to move the NPC during a cutscene
func cutscene_move(target_position: Vector2, speed_multiplier: float = 1.0, face_direction: Vector2 = Vector2.ONE) -> void:
	if face_direction in [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]:
		for key in ANIMATION_PARAMETERS.keys():
			animation_tree.set(ANIMATION_PARAMETERS[key], face_direction)
	_anim_state.travel("walk")
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.25 * speed_multiplier).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	_anim_state.travel("idle")
