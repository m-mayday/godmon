class_name Learnset
extends Resource
## Class to build learnsets for a Species
## Should be replaced by a Dictionary when type hinting is supported

@export var level: int ## Level at which the move will be learned
@export var move: Constants.MOVES ## Move that will be learned
