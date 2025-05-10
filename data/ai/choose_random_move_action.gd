@tool
extends ActionLeaf

func tick(_actor: Node, blackboard: Blackboard) -> int:
	var battler: Battler = blackboard.get_value("battler")
	var usable_moves: Array[Move] = []
	
	for move in battler.pokemon.moves:
		print(battler.pokemon.name, " - ", move.name)
		if battler.can_use_move(move):
			usable_moves.push_back(move)
	
	if len(usable_moves) > 0:
		var move: Move = usable_moves.pick_random()
		battler.battle.queue_move(move, battler)
		print("{0} randomly chose {1}".format([battler.pokemon.name, move.name]))
	# TODO: else: Struggle
	return BeehaveNode.SUCCESS
