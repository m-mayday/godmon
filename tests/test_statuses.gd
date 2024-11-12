extends GutTest

class TestBurn extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_takes_residual_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.opponent_team[0].set_status(Constants.STATUSES.BURN)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BURN)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - battle.opponent_team[0].pokemon.stats.hp / 16)


	func test_halves_physical_moves_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.opponent_team[0].set_status(Constants.STATUSES.BURN)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BURN)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - 3) # Normally 7


	func test_does_not_halve_special_moves_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.opponent_team[0].set_status(Constants.STATUSES.BURN)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.GUST), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BURN)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - 7)


	func test_fire_types_are_immune():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.opponent_team[0].set_status(Constants.STATUSES.BURN)
		battle.player_team[0].set_status(Constants.STATUSES.BURN)

		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BURN)
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestFreeze extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Chance - Status - Damage
	var freeze_chance = [[19, Constants.STATUSES.NONE, 6], [20, Constants.STATUSES.FREEZE, 0]]
	
	func test_chance_of_thawing_out(params = use_parameters(freeze_chance)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.FREEZE)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random").to_return(params[0]).when_passed(100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, params[1])
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[2])


	# TODO: Add Matcha Gotcha and uncomment when moves are implemented
	#var defrost_moves = [Constants.MOVES.FLAME_WHEEL, Constants.MOVES.SACRED_FIRE, Constants.MOVES.FLARE_BLITZ, Constants.MOVES.FUSION_FLARE, Constants.MOVES.SCALD, Constants.MOVES.STEAM_ERUPTION, Constants.MOVES.BURN_UP, Constants.MOVES.PYRO_BALL, Constants.MOVES.SCORCHING_SANDS]
#
	#func test_thaws_out_when_using_defrosting_move(params = use_parameters(defrost_moves)):
		#var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		#var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		#
		#battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		#
		#battle.player_team[0].set_status(Constants.STATUSES.FREEZE)
		#
		#battle.queue_move(Constants.get_move_by_id(params), battle.player_team[0], battle.opponent_team[0])
		#
		#stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		#stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		#stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		#stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()#

		#battle._play_turn()
		#

		#assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		#assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	#func test_thaws_out_when_hit_by_defrosting_move(params = use_parameters(defrost_moves)):
		#var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		#var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		#
		#battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		#
		#battle.player_team[0].set_status(Constants.STATUSES.FREEZE)
		#
		#battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		#
		#stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		#stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		#stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		#stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()#

		#battle._play_turn()
		#

		#assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		#assert_not_same(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)

	var fire_moves = [Constants.MOVES.FIRE_PUNCH, Constants.MOVES.EMBER]

	func test_thaws_out_after_being_hit_by_fire_move(params = use_parameters(fire_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.FREEZE)
		
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_not_same(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)

	# TODO: Test fire status move do not thaw out the target

	# TODO: Uncomment when Ice type is implemented
	#func test_ice_types_are_immune():
		#var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		#var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		#
		#battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		#
		#battle.opponent_team[0].set_status(Constants.STATUSES.FREEZE)
		#battle.player_team[0].set_status(Constants.STATUSES.FREEZE)
#
		#assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.FREEZE)
		#assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestParalysis extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_halves_speed():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		var original_speed = battle.player_team[0].get_calculated_speed()
		battle.player_team[0].set_status(Constants.STATUSES.PARALYSIS)

		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.PARALYSIS)
		assert_eq(battle.player_team[0].get_calculated_speed(), original_speed / 2)

	# Chance - Damage
	var paralysis_chance = [[25, 6], [24, 0]]
	
	func test_chance_of_being_fully_paralyzed(params = use_parameters(paralysis_chance)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.PARALYSIS)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random").to_return(params[0]).when_passed(100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])

	# TODO: Uncomment when electric type is implemented
	#func test_electric_types_are_immune():
		#var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		#var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		#
		#battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		#
		#battle.opponent_team[0].set_status(Constants.STATUSES.PARALYSIS)
		#battle.player_team[0].set_status(Constants.STATUSES.PARALYSIS)
#
		#assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.PARALYSIS)
		#assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestPoison extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_takes_residual_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.POISON)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.POISON)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - battle.player_team[0].pokemon.stats.hp / 8)

	# TODO: Add Steel types to this test
	func test_poison_types_are_immune():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.opponent_team[0].set_status(Constants.STATUSES.POISON)
		battle.player_team[0].set_status(Constants.STATUSES.POISON)

		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.POISON)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestBadPoison extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_takes_residual_damage_increasing_each_turn():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.BAD_POISON)
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		
		var counter = 1
		while not battle.player_team[0].is_fainted():
			var current_hp = battle.player_team[0].pokemon.current_hp
			stub(battle, "run_battle_event").to_do_nothing()
			battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.player_team[0], battle.opponent_team[0])
			battle._play_turn()

			assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.BAD_POISON)
			assert_has(battle.player_team[0].battler_flags, "bad_poison")
			assert_eq(battle.player_team[0].pokemon.current_hp, maxi(current_hp - int(battle.player_team[0].pokemon.stats.hp / 16) * counter, 0))
			counter += 1
		assert_lt(counter, 15) # Very difficult for any battler to have enough hp

	# TODO: Add Steel types to this test
	func test_poison_types_are_immune():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.opponent_team[0].set_status(Constants.STATUSES.BAD_POISON)
		battle.player_team[0].set_status(Constants.STATUSES.BAD_POISON)

		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.BAD_POISON)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestSleep extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_prevents_battler_from_moving():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
	
		battle.player_team[0].set_status(Constants.STATUSES.SLEEP)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy

		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.SLEEP)
		assert_has(battle.player_team[0].battler_flags, "sleep")
		assert_between(battle.player_team[0].battler_flags["sleep"], 2, 4) # Amount of turns
		stub(battle, "run_battle_event").to_do_nothing()
		var sleep_count = battle.player_team[0].battler_flags["sleep"]
		battle._play_turn()
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.SLEEP)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_has(battle.player_team[0].battler_flags, "sleep")
		assert_eq(battle.player_team[0].battler_flags["sleep"], sleep_count - 1)


	func test_wakes_up_before_using_move():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
	
		battle.player_team[0].set_status(Constants.STATUSES.SLEEP)
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy

		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.SLEEP)
		assert_has(battle.player_team[0].battler_flags, "sleep")
		assert_between(battle.player_team[0].battler_flags["sleep"], 2, 4) # Amount of turns
		stub(battle, "run_battle_event").to_do_nothing()
		battle.player_team[0].battler_flags["sleep"] = 1 # So it wakes up this turn
		battle._play_turn()
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_does_not_have(battle.player_team[0].battler_flags, "sleep")
