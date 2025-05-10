@tool
extends ActionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	var battler: Battler = blackboard.get_value("battler")
	var trainer: Trainer = battler.pokemon.trainer
	
	var best_score: float = -1.0
	var best_move: Move = null
	var best_target: Battler = null
	
	for move in battler.pokemon.moves:
		var targets: Array[Battler] = battler.battle.get_move_targets(battler, move.target)
		
		for target in targets:
			var current_pair_score: float = move.power
			var type_modifier := 1.0
			for target_type in target.pokemon.species.types:
				if target_type.immunities.has(move.type):
					current_pair_score = 0.0
					continue
				elif target_type.weaknesses.has(move.type):
					type_modifier *= 2.0
				elif target_type.resistances.has(move.type):
					type_modifier *= 0.5
			current_pair_score *= type_modifier
			
			## Prefer under leveled targets
			if trainer.ai_flags.has(Constants.TRAINER_AI_FLAGS.ConsiderLevel):
				if target.pokemon.level < battler.pokemon.level:
					current_pair_score *= 1.5
			
			
			## Prefer moves that hit more than one foe in battles with more than one pokemon per side
			if trainer.ai_flags.has(Constants.TRAINER_AI_FLAGS.ConsiderBattleSize):
				if battler.battle.battle_size != Constants.BATTLE_SIZE.NORMAL and move.target == Constants.MOVE_TARGET.ALL_ADJACENT_FOES:
					current_pair_score *= 2.0
			
			if current_pair_score > best_score:
				best_score = current_pair_score
				best_move = move
				best_target = target
	
	if best_move != null:
		blackboard.set_value("best_move", best_move)
		blackboard.set_value("best_target", best_target)
		print("{0} chose {1} targeting {2} with score {3}".format([battler.pokemon.name, best_move.name, best_target.pokemon.name, best_score]))
	else:
		print("Couldn't find any valid move for ", battler.pokemon.name)
	return BeehaveNode.SUCCESS
