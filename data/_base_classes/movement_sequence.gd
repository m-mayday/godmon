class_name MovementSequence
extends Resource

enum TYPES {
	WALK,
	TURN,
}

enum DIRECTIONS {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

@export var type: TYPES
@export var direction: DIRECTIONS


func direction_to_vector(p_direction: DIRECTIONS) -> Vector2:
	if p_direction == DIRECTIONS.UP:
		return Vector2.UP
	elif p_direction == DIRECTIONS.DOWN:
		return Vector2.DOWN
	elif p_direction == DIRECTIONS.LEFT:
		return Vector2.LEFT
	elif p_direction == DIRECTIONS.RIGHT:
		return Vector2.RIGHT
	return Vector2.ZERO
