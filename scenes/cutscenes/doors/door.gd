extends Cutscene
class_name Door

func transition(player: Area2D, position: Vector2) -> void:
	_is_cutscene_in_progress = true
	print("animation_open")
	var tween = create_tween()
	tween.tween_property(player, "position", position, 0.25).set_trans(Tween.TRANS_LINEAR)
	tween.play()
	await tween.finished
	print("animation_close")
	print("transition")
	player.visible = false
	_is_cutscene_in_progress = false
