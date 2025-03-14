extends Cutscene
class_name Stairs

@export var target_location: Vector2 ## Scene path to load
@export_enum("UP:-1", "DOWN:1") var stairs_direction: int = -1
@export var player_face_direction: Vector2 = Vector2.RIGHT ## The direction of the player to "enter" this door
@export var tiles: int = 1 ## Amount of tiles to move the player when "entering" this door


## Animates the player going up/down stairs and moves it to the target location
func _execute() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var mover = player.get_node("GridMovement")
	mover.cutscene_move(Vector2(player.position.x + tiles*Constants.TILE_SIZE * stairs_direction * -1, player.position.y + tiles*Constants.TILE_SIZE / 2 * stairs_direction), tiles)
	await get_tree().root.get_node("Main").play_transition(1.5)
	player.position = Vector2(target_location.x + tiles * Constants.TILE_SIZE * player_face_direction.x * -1, target_location.y + (tiles * Constants.TILE_SIZE / 2) * stairs_direction * -1)
	await mover.cutscene_move(target_location, tiles)
	


## Runs the cutscene
func execute():
	run()
