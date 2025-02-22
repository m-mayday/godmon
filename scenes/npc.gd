extends Sprite2D

var interactable: bool = false


func _ready() -> void:
	SignalBus.input_paused.connect(_on_interaction)


func _on_area_2d_area_entered(area: Area2D) -> void:
	interactable = true
	

func _on_area_2d_area_exited(area: Area2D) -> void:
	interactable = false


func _on_interaction(_paused: bool) -> void:
	if interactable:
		var player: Node = get_parent().get_node("Player/GridMovement")
		var player_direction: int = player._face_direction
		var animation: String = "idle_down"
		if player_direction == 1:
			animation = "idle_up"
		elif player_direction == 2:
			animation = "idle_left"
		elif player_direction == 3:
			animation = "idle_right"
		$AnimationPlayer.play(animation)
