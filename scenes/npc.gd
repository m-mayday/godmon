extends Sprite2D

var interactable: bool = false


func _ready() -> void:
	SignalBus.input_paused.connect(_on_interaction)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	interactable = true
	

func _on_area_2d_area_exited(_area: Area2D) -> void:
	interactable = false


func _on_interaction(_paused: bool) -> void:
	if interactable:
		var player: Node = get_tree().get_first_node_in_group("player")
		var player_direction: Vector2 = player.face_direction
		var animation: String = "idle_down"
		if player_direction == Vector2.DOWN:
			animation = "idle_up"
		elif player_direction == Vector2.RIGHT:
			animation = "idle_left"
		elif player_direction == Vector2.LEFT:
			animation = "idle_right"
		$AnimationPlayer.play(animation)
