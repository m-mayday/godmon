extends Node2D

@export var current_scene_node: Node
@export var animator: AnimationPlayer
@export var transition_layer: CanvasLayer
@export var transition_color: ColorRect


var current_scene: Node
var previous_scene: Node


func _ready() -> void:
	current_scene = current_scene_node.get_child(0)
	transition_layer.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"): # Speed up
		if Engine.time_scale == 5.0:
			Engine.time_scale = 1.0
		else:
			Engine.time_scale = 5.0


func change_scene(new_scene: String, delete: bool = false, data: Array = []) -> void:
	if current_scene != null:
		if delete:
			current_scene.queue_free()
		var scene = load(new_scene).instantiate()
		if scene.has_method("with_data"):
			scene.with_data(data)
		previous_scene = current_scene
		var previous_mode = previous_scene.process_mode
		previous_scene.process_mode = Node.PROCESS_MODE_DISABLED
		transition_layer.visible = true
		animator.play("fade_in")
		await animator.animation_finished
		transition_color.color.a = 0
		transition_layer.visible = false
		current_scene_node.remove_child(previous_scene)
		current_scene = scene
		current_scene_node.add_child(scene)
		previous_scene.process_mode = previous_mode


func to_previous_scene(free_current: bool = true) -> void:
	transition_layer.visible = true
	animator.play("fade_in")
	await animator.animation_finished
	current_scene_node.remove_child(current_scene)
	current_scene.queue_free()
	transition_color.color.a = 0
	transition_layer.visible = false
	current_scene = previous_scene
	current_scene_node.add_child(previous_scene)
