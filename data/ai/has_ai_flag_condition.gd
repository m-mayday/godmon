@tool
extends ConditionLeaf

@export var ai_flag: Constants.TRAINER_AI_FLAGS

func tick(_actor: Node, blackboard: Blackboard) -> int:
	var battler: Battler = blackboard.get_value("battler")
	if battler.pokemon.trainer.ai_flags.has(ai_flag):
		return BeehaveNode.SUCCESS
	return BeehaveNode.FAILURE
