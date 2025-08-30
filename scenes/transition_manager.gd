class_name TransitionManager
extends CanvasLayer

@export var animator: AnimationPlayer
@export var color_rect: ColorRect

func _ready() -> void:
	animator.animation_finished.connect(_fade_out_clean_up)


func fade_in(speed: float = 1.0) -> Signal:
	visible = true
	animator.play("fade_in", -1, speed)
	return animator.animation_finished


func fade_out() -> Signal:
	visible = true
	animator.play("fade_out")
	return animator.animation_finished


func reset_state() -> void:
	color_rect.color.a = 0
	visible = false


func _fade_out_clean_up(animation: String) -> void:
	if animation == "fade_out":
		reset_state()
