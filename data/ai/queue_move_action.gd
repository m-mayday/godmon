@tool
extends ActionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	var battler: Battler = blackboard.get_value("battler")
	var chosen_move: Move = blackboard.get_value("best_move", null)
	var target: Battler = blackboard.get_value("best_target", null)
	
	if chosen_move == null:
		var usable_moves: Array[Move] = []
		for move in battler.pokemon.moves:
			if battler.can_use_move(move):
				usable_moves.push_back(move)
				
		# TODO: If usable_moves.is_empty(): use Sruggle
		chosen_move = usable_moves.pick_random()
	
	battler.battle.queue_move(chosen_move, battler, target)
	return BeehaveNode.SUCCESS
