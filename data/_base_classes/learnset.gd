class_name Learnset
extends Resource
## Class to build learnsets for a Species
## Should be replaced by a Dictionary when nested type hinting is supported (Dictionary[int, Array[Moves]])

@export var moves: Array[Constants.MOVES] ## Moves that will be learned
