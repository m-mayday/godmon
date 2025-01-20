extends Node2D

@export var current_scene_node: Node
@export var animator: AnimationPlayer
@export var canvas: CanvasModulate


var current_scene: Node
var previous_scene: Node


func _ready() -> void:
	current_scene = current_scene_node.get_child(0)


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
		animator.play("fade_out")
		await animator.animation_finished
		canvas.color = Color("white")
		current_scene_node.remove_child(previous_scene)
		current_scene = scene
		current_scene_node.add_child(scene)
		previous_scene.process_mode = previous_mode


func to_previous_scene() -> void:
	current_scene_node.remove_child(current_scene)
	current_scene = previous_scene
	current_scene_node.add_child(previous_scene)
