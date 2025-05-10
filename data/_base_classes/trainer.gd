class_name Trainer
extends Resource
## Represents a Trainer who can battle

@export var name: String ## Name of the trainer, as it'll show during battle.

@export var party: Array[Pokemon]: ## The party of the trainer
	set(value):
		party = value
		for pokemon in party:
			pokemon.trainer = self
			
@export var trainer_class: String ## The trainer's class
@export var defeat_dialogue: DialogueResource ## The dialogue to show in battle after they are defeated
@export var ai_scene: PackedScene: ## The AI the tainer should use
	set(value):
		ai = value.instantiate().get_child(0)

@export var ai_flags: Array[Constants.TRAINER_AI_FLAGS] ## AI flags that will determine how the trainer will behave
@export var defeat_flag: String ## The key to increase once the trainer is defeated

# Individual nodes can't be exported from resources
var ai: BeehaveTree ## The AI node to call to make decisions
