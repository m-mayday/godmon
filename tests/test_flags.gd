extends GutTest

# Most flags are tested elsewhere (moves, abilities, etc)

class TestConfusion extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Chance - Confused damage - Target damage
	var confusion_chance = [[32, 0, 6], [33, 6, 0]]
	
	func test_confusion_damage(params = use_parameters(confusion_chance)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].battler_flags["confusion"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.CONFUSION, battle.player_team[0]),
			4,
		]
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random").to_return(params[0]).when_passed(100) # Confusion chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "confusion")
		assert_eq(battle.player_team[0].battler_flags["confusion"][1], 3)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - params[1])
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[2])
