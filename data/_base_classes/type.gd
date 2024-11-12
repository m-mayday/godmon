class_name Type
extends Resource
## Reprents a Pokemon or Move type

@export var id: Constants.TYPES ## The type id
@export var name: StringName = "Unnamed" ## The type name to be displayed
@export var weaknesses: Array[Constants.TYPES] ## The types this type is weak to
@export var resistances: Array[Constants.TYPES] ## The types this type resists
@export var immunities: Array[Constants.TYPES] ## The types this type is immune to
