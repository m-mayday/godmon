class_name Cutscene
extends Node
## A Cutscene class based on GDQuest's OpenRPG's https://github.com/gdquest-demos/godot-open-rpg


## Indicates if a cutscene is currently running.
static var _is_cutscene_in_progress: = false:
	set(value):
		if _is_cutscene_in_progress != value:
			_is_cutscene_in_progress = value
			SignalBus.input_paused.emit(value)


## Returns true if a cutscene is currently running.
static func is_cutscene_in_progress() -> bool:
	return _is_cutscene_in_progress


## Play out the specific events of the cutscene.
## This is intended to be overridden by derived cutscene types.
func _execute() -> void:
	pass


## Execute the cutscene.
func run() -> void:
	_is_cutscene_in_progress = true
	
	# The _execute method may or may not be asynchronous, depending on the particular cutscene.
	@warning_ignore("redundant_await")
	await _execute()
	
	_is_cutscene_in_progress = false
