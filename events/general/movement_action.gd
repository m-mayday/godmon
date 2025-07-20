class_name MovementAction
extends EventAction
## Action to move a node in a given direction.

## The types of movement.
enum TYPES {
	WALK,
	TURN,
}

## The directions the node can be moved to.
enum DIRECTIONS {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

const _directions: Dictionary[DIRECTIONS, Vector2] = {
	DIRECTIONS.UP: Vector2.UP,
	DIRECTIONS.DOWN: Vector2.DOWN,
	DIRECTIONS.LEFT: Vector2.LEFT,
	DIRECTIONS.RIGHT: Vector2.RIGHT,
}

@export var target: EventTargetResolver
@export var type: TYPES ## The type of movement to be applied to the node.
@export var direction: DIRECTIONS ## The direction of the movement.
@export var tiles: int = 1 ## The amount of tiles to move in the given direction.


## Node is used to get the node specified as [code]node_path[/code] when [code]is_player = false[/code]
## It moves the node in the specified direction for the specified amount of tiles
func execute(node: Node) -> bool:
	var target_node: Node2D = target.resolve(node)
	if target_node == null:
		return false
	var dir: Vector2 = _directions[direction]
	if type == TYPES.WALK:
		if tiles == 0:
			var executed: bool = await target_node.walk((target_node.position))
			return executed
		for i in range(tiles):
			var executed: bool = await target_node.walk((target_node.position + (dir * Constants.TILE_SIZE)).snapped(Vector2.ONE * Constants.TILE_SIZE))
			if not executed:
				return executed
	elif type == TYPES.TURN:
		await target_node.turn(dir)
	return true
