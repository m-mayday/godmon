extends GutTest

class TestMultiStrikeMoves extends GutTest:
	var battle = null
	var action = null
	
	func after_each():
		battle = null
		action = null
	
	var chance_params = [[0, 2], [1, 2], [2, 2], [3, 2], [4, 2], [5, 2], [6, 2], [7, 3], [8, 3], [9, 3], [10, 3], [11, 3], [12, 3], [13, 3], [14, 4], [15, 4], [16, 4], [17, 5], [18, 5], [19, 5]]
	
	func test_number_of_hits(params = use_parameters(chance_params)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.DOUBLE_SLAP)
		move.current_pp = move.base_pp
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		action = partial_double(MoveAction).new(move, battle.player_team[0], battle.opponent_team[0], battle)
		
		stub(action, "_step_accuracy_check").to_return(true)
		stub(battle, "random").to_return(params[0]).when_passed(20)
		stub(battle, "run_battle_event").to_do_nothing()
		
		action.execute()
		
		assert_call_count(action, "_deal_damage", params[1])

class TestMultiturnMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var two_turn_moves = [Constants.MOVES.FLY, Constants.MOVES.SOLAR_BEAM, Constants.MOVES.DIG, Constants.MOVES.SKULL_BASH, Constants.MOVES.SKY_ATTACK, Constants.MOVES.RAZOR_WIND]
	
	func test_executes_in_two_turns(params = use_parameters(two_turn_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "twoturnmove")
		assert_eq(move.current_pp, move.total_pp - 1)
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_does_not_have(battle.player_team[0].battler_flags, "twoturnmove")
		assert_eq(move.current_pp, move.total_pp - 1) # It only deducts PP once


class TestBurnChanceMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var burn_chance_moves = [Constants.MOVES.FIRE_PUNCH, Constants.MOVES.EMBER, Constants.MOVES.FLAMETHROWER, Constants.MOVES.FIRE_BLAST, Constants.MOVES.FLAME_WHEEL]
	
	func test_burns_opponent(params = use_parameters(burn_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BURN)


	func test_does_not_burn_opponent(params = use_parameters(burn_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestFreezeChanceMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var freeze_chance_moves = [Constants.MOVES.ICE_PUNCH, Constants.MOVES.ICE_BEAM, Constants.MOVES.BLIZZARD, Constants.MOVES.POWDER_SNOW]
	
	func teste_freezes_opponent(params = use_parameters(freeze_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.FREEZE)


	func test_does_not_freeze_opponent(params = use_parameters(freeze_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		

class TestParalyzeChanceMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var paralyze_chance_moves = [Constants.MOVES.THUNDER_PUNCH, Constants.MOVES.THUNDER_SHOCK, Constants.MOVES.THUNDERBOLT, Constants.MOVES.LICK, Constants.MOVES.BODY_SLAM, Constants.MOVES.THUNDER]
	
	func test_paralyzes_opponent(params = use_parameters(paralyze_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.PARALYSIS)


	func test_does_not_paralyze_opponent(params = use_parameters(paralyze_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestOHKOMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var ohko_moves = [Constants.MOVES.GUILLOTINE, Constants.MOVES.HORN_DRILL, Constants.MOVES.FISSURE]
	
	func test_ohkos_opponent(params = use_parameters(ohko_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_fainted())
		
		
	func test_fails_against_higher_level_opponent(params = use_parameters(ohko_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 5)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 6)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)		
		assert_false(battle.opponent_team[0].is_fainted())


class TestSwordsDance extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_raises_attack_stage_by_2():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.SWORDS_DANCE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 2)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestGust extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_deals_normal_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.GUST)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 6)
	
	
	func test_hits_flying_opponent_for_double_power():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.GUST)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.FLY), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_semi_invulnerable())
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 12)


class TestForceSwitchMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var force_switch_moves = [Constants.MOVES.WHIRLWIND, Constants.MOVES.ROAR]
	
	func test_forces_switch_out(params = use_parameters(force_switch_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard, blastoise] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_not_same(battle.sides[0].active[0].pokemon.species.species_id, charizard.species.species_id)
		assert_eq(battle.sides[0].active[0].pokemon.species.species_id, blastoise.species.species_id)


	func test_fails_against_semi_invulnerable_target(params = use_parameters(force_switch_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard, blastoise] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.FLY), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.sides[0].active[0].is_semi_invulnerable())
		assert_eq(battle.sides[0].active[0].pokemon.species.species_id, charizard.species.species_id)


class TestTrapTargetMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var trap_target_moves = [Constants.MOVES.BIND, Constants.MOVES.WRAP, Constants.MOVES.FIRE_SPIN, Constants.MOVES.CLAMP]
	
	func test_binds_target(params = use_parameters(trap_target_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 1)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.player_team[0].battler_flags, "bound")
		assert_between(battle.player_team[0].battler_flags["bound"][1], 3, 4) # Between 4-5 turns (One turn already passed)
		assert_almost_eq(charizard.current_hp, charizard.stats.hp - int(charizard.stats.hp / 8), 5)


class TestFlinchChanceMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var flinch_chance_moves = [Constants.MOVES.STOMP, Constants.MOVES.ROLLING_KICK, Constants.MOVES.HEADBUTT, Constants.MOVES.BITE, Constants.MOVES.BONE_CLUB, Constants.MOVES.WATERFALL, Constants.MOVES.ROCK_SLIDE, Constants.MOVES.HYPER_FANG]
	
	func test_flinches_opponent(params = use_parameters(flinch_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")


	func test_does_not_flinch_opponent(params = use_parameters(flinch_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_not_same(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")


class TestDoublePowerOnMinimize extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var double_damage_on_minimize_moves = [[Constants.MOVES.STOMP, 4, 6], [Constants.MOVES.BODY_SLAM, 5, 8]]
	
	func test_deals_normal_damage(params = use_parameters(double_damage_on_minimize_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])
	
	
	func test_hits_minimized_opponent_for_double_power(params = use_parameters(double_damage_on_minimize_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.MINIMIZE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.opponent_team[0].battler_flags, "minimize")
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[2])


class TestTwoHitMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var two_hit_moves = [Constants.MOVES.DOUBLE_KICK, Constants.MOVES.BONEMERANG, Constants.MOVES.TWINEEDLE]
	
	func test_number_of_hits_is_two(params = use_parameters(two_hit_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		var action = partial_double(MoveAction).new(move, battle.player_team[0], battle.opponent_team[0], battle)
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(action, "_step_accuracy_check").to_return(true)
		
		battle.battle_actions.push_back(action)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_call_count(action, "_deal_damage", 2)
		
		
class TestCrashDamage extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var crash_damage_moves = [Constants.MOVES.JUMP_KICK, Constants.MOVES.HIGH_JUMP_KICK]
	
	func test_user_takes_half_damage_on_miss(params = use_parameters(crash_damage_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(100).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_almost_eq(charizard.current_hp, charizard.stats.hp - int(charizard.stats.hp / 2), 1)
		
	
	func test_user_does_not_take_damage_on_hit(params = use_parameters(crash_damage_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(charizard.current_hp, charizard.stats.hp)


class TestLowerAccuracyByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_accuracy_by_one_moves = [Constants.MOVES.SAND_ATTACK, Constants.MOVES.SMOKESCREEN, Constants.MOVES.KINESIS, Constants.MOVES.FLASH]
	
	func test_lowers_accuracy_by_one(params = use_parameters(lower_accuracy_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, -1)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestRecoil25Percent extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var recoil_25_percent_moves = [[Constants.MOVES.TAKE_DOWN, 7], [Constants.MOVES.SUBMISSION, 3]]
	
	func test_user_takes_25_percent_recoil_damage(params = use_parameters(recoil_25_percent_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "random_range").to_return(85).when_passed(85, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_almost_eq(charizard.current_hp, charizard.stats.hp - int(params[1] / 4), 2)


class TestLockingMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var locking_moves = [Constants.MOVES.THRASH, Constants.MOVES.PETAL_DANCE]
	
	func test_locks_user_into_move_and_confuses_on_end(params = use_parameters(locking_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(move.current_pp, move.total_pp - 1)
		assert_has(battle.player_team[0].battler_flags, "lockedmove")
		assert_between(battle.player_team[0].battler_flags["lockedmove"][3], 2, 3)
		var duration = battle.player_team[0].battler_flags["lockedmove"][3]
		for turn in duration:
			stub(battle, "run_battle_event").to_do_nothing()
			battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
			battle._play_turn()
			#await wait_for_signal(battle.turn_ended, 5)
		assert_does_not_have(battle.player_team[0].battler_flags, "lockedmove")
		assert_has(battle.player_team[0].battler_flags, "confusion")
		assert_eq(move.current_pp, move.total_pp - 1) # It only deducts PP once


class TestRecoil33Percent extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var recoil_33_percent_moves = [[Constants.MOVES.DOUBLE_EDGE, 10]]
	
	func test_user_takes_33_percent_recoil_damage(params = use_parameters(recoil_33_percent_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "random_range").to_return(85).when_passed(85, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_almost_eq(charizard.current_hp, charizard.stats.hp - int(params[1] / 3), 2)


class TestLowerDefenseByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_defense_by_one_moves = [Constants.MOVES.TAIL_WHIP, Constants.MOVES.LEER]
	
	func test_lowers_defense_one(params = use_parameters(lower_defense_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, -1)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestPoisonChanceMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var poison_chance_moves = [Constants.MOVES.POISON_STING, Constants.MOVES.TWINEEDLE, Constants.MOVES.SMOG, Constants.MOVES.SLUDGE, Constants.MOVES.SLUDGE_BOMB]
	
	func test_poisons_opponent(params = use_parameters(poison_chance_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.POISON)


	func test_does_not_poison_opponent(params = use_parameters(poison_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestLowerAttackByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_attack_by_one_moves = [Constants.MOVES.GROWL]
	
	func test_lowers_defense_one(params = use_parameters(lower_attack_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, -1)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestInflictSleepMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var inflict_sleep_moves = [Constants.MOVES.SING, Constants.MOVES.SLEEP_POWDER, Constants.MOVES.HYPNOSIS, Constants.MOVES.LOVELY_KISS, Constants.MOVES.SPORE]
	
	func test_puts_opponent_to_sleep(params = use_parameters(inflict_sleep_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.SLEEP)


class TestInflictConfusionMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var inflict_confusion_moves = [Constants.MOVES.SUPERSONIC, Constants.MOVES.CONFUSE_RAY, Constants.MOVES.SWEET_KISS]
	
	func test_confuses_opponent(params = use_parameters(inflict_confusion_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.opponent_team[0].battler_flags, "confusion")


class TestFixedDamageMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var fixed_damage_moves = [[Constants.MOVES.SONIC_BOOM, 20], [Constants.MOVES.DRAGON_RAGE, 40]]
	
	func test_deals_fixed_damage_opponent(params = use_parameters(fixed_damage_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


class TestDisable extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_disables_opponent_move():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(Constants.MOVES.DISABLE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.opponent_team[0].battler_flags, "disable")
		assert_eq(battle.opponent_team[0].battler_flags["disable"][1], Constants.MOVES.SPLASH)
		assert_eq(battle.opponent_team[0].battler_flags["disable"][2], 3) # Duration: 4 minus the turn that just passed


class TestLowerSpecialDefenseByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_special_defense_by_one_moves = [Constants.MOVES.ACID, Constants.MOVES.PSYCHIC]
	
	func test_lowers_special_defense_one(params = use_parameters(lower_special_defense_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, -1)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestMist extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_protects_against_lowering_stat_changes():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.MIST)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TAIL_WHIP), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.player_team[0].side.side_flags, "mist")
		assert_eq(battle.player_team[0].side.side_flags["mist"][2], 4) # Duration: 5 minus the turn that just passed
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestConfuseChanceMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var confuse_chance_moves = [Constants.MOVES.PSYBEAM, Constants.MOVES.CONFUSION, Constants.MOVES.DIZZY_PUNCH]
	
	func test_confuses_opponent(params = use_parameters(confuse_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.opponent_team[0].battler_flags, "confusion")
		
	func test_does_not_confuse_opponent(params = use_parameters(confuse_chance_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_does_not_have(battle.opponent_team[0].battler_flags, "confusion")


class TestLowerSpeedByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_speed_by_one_moves = [Constants.MOVES.BUBBLE_BEAM, Constants.MOVES.CONSTRICT, Constants.MOVES.BUBBLE]
	
	func test_lowers_speed_one(params = use_parameters(lower_speed_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, -1)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestAuroraBeam extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
		
	func test_lowers_attack_by_one():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		var move = Constants.get_move_by_id(Constants.MOVES.AURORA_BEAM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, -1)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)
		
		
	func test_does_not_lower_attack():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.AURORA_BEAM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestRechargeMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var recharge_moves = [Constants.MOVES.HYPER_BEAM]
	
	func test_user_needs_to_recharge(params = use_parameters(recharge_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()

		assert_has(battle.player_team[0].battler_flags, "recharge")
		assert_eq(move.current_pp, move.total_pp - 1)
		var hp = battle.opponent_team[0].pokemon.current_hp
		assert_not_same(hp, battle.opponent_team[0].pokemon.stats.hp) # Opponent was hurt
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_does_not_have(battle.player_team[0].battler_flags, "recharge")
		assert_eq(hp, battle.opponent_team[0].pokemon.current_hp) # Opponent's HP didn't change because user was recharging
		assert_eq(move.current_pp, move.total_pp - 1) # It only deducts PP once


class TestLowKick extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var weight_base_power = [[200.0, 5], [205.0, 5], [165.0, 5], [88.0, 4], [30.0, 3], [11.0, 2], [0.5, 1]]
	
	func test_damage_varies_by_opponent_weight(params = use_parameters(weight_base_power)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.species.weight = params[0]
		var move = Constants.get_move_by_id(Constants.MOVES.LOW_KICK)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		var expected_hp = battle.opponent_team[0].pokemon.stats.hp - params[1]
		assert_between(battle.opponent_team[0].pokemon.current_hp, expected_hp - 1, expected_hp)


class TestLevelDamageMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var level_damage_moves = [Constants.MOVES.SEISMIC_TOSS, Constants.MOVES.NIGHT_SHADE]
	
	func test_deals_level_as_damage(params = use_parameters(level_damage_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 50)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 50)


class TestDrain50PercentMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var drain_50_percent_moves = [[Constants.MOVES.ABSORB, 9], [Constants.MOVES.MEGA_DRAIN, 18], [Constants.MOVES.LEECH_LIFE, 21]]
	
	func test_heals_50_percent_of_dealt_damage(params = use_parameters(drain_50_percent_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		venusaur.current_hp -= 20
		var hp = venusaur.current_hp
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_almost_eq(venusaur.current_hp, hp + int(params[1] / 2), 2)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


class TestSeedingMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var seeding_moves = [Constants.MOVES.LEECH_SEED]
	
	## TODO: Test switches in double/triple battles
	func test_seeds_opponent(params = use_parameters(seeding_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		venusaur.current_hp -= 20
		var hp = venusaur.current_hp
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.opponent_team[0].battler_flags, "seeded")
		assert_eq(battle.opponent_team[0].battler_flags["seeded"][2], 0) # Position to heal (original user's)
		assert_almost_eq(venusaur.current_hp, hp + int(charizard.stats.hp / 8), 2)


class TestGrowth extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_increases_attack_stats_by_one():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.GROWTH)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 1)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 1)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestInflictPoisonMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var inflict_poison_moves = [Constants.MOVES.POISON_POWDER, Constants.MOVES.POISON_GAS]
	
	func test_puts_opponent_to_sleep(params = use_parameters(inflict_poison_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.POISON)


class TestInflictParalysisMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var inflict_paralysis_moves = [Constants.MOVES.STUN_SPORE, Constants.MOVES.THUNDER_WAVE, Constants.MOVES.GLARE]
	
	func test_puts_opponent_to_sleep(params = use_parameters(inflict_paralysis_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.PARALYSIS)


class TestLowerSpeedByTwo extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_speed_by_two_moves = [Constants.MOVES.STRING_SHOT, Constants.MOVES.COTTON_SPORE, Constants.MOVES.SCARY_FACE]
	
	func test_lowers_speed_two(params = use_parameters(lower_speed_by_two_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, -2)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestThunder extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var bypassable_moves = [Constants.MOVES.FLY]
	
	func test_hits_semi_invulnerable_target(params = use_parameters(bypassable_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.THUNDER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_semi_invulnerable())
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


class TestEarthquake extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_deals_normal_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.EARTHQUAKE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 5)
	
	
	func test_hits_underground_opponent_for_double_power():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.EARTHQUAKE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.DIG), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_semi_invulnerable())
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 9)


class TestFissure extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_hits_underground_target():
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var move = Constants.get_move_by_id(Constants.MOVES.FISSURE)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.DIG), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_semi_invulnerable())
		assert_eq(battle.opponent_team[0].pokemon.current_hp, 0)


class TestToxic extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_always_hits_if_used_by_poison_type():
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var move = Constants.get_move_by_id(Constants.MOVES.TOXIC)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(100).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BAD_POISON)
		
	
	func test_can_fail_if_not_used_by_poison_type():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.TOXIC)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(100).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	
	var semi_invulnerable_moves = [Constants.MOVES.FLY, Constants.MOVES.DIG]
	
	func test_hits_semi_invulnerable_target_if_used_by_poison_type(params = use_parameters(semi_invulnerable_moves)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 30)
		var move = Constants.get_move_by_id(Constants.MOVES.TOXIC)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_semi_invulnerable())
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BAD_POISON)


	func test_does_not_hit_semi_invulnerable_target_if_not_used_by_poison_type(params = use_parameters(semi_invulnerable_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE, 30)
		var move = Constants.get_move_by_id(Constants.MOVES.TOXIC)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [blastoise] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].is_semi_invulnerable())
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestIncreasesAttackByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var increase_attack_by_one_moves = [Constants.MOVES.MEDITATE, Constants.MOVES.SHARPEN]
	
	func test_increases_attack_one(params = use_parameters(increase_attack_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 1)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestIncreasesSpeedByTwo extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var increase_speed_by_two_moves = [Constants.MOVES.AGILITY]
	
	func test_increases_speed_two(params = use_parameters(increase_speed_by_two_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 2)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestRage extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_attack_increases_when_hit():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.RAGE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_not_same(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_eq(battle.player_team[0].stat_stages.attack, 1)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)

## TODO: Teleport test

class TestLowerDefenseByTwo extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_defenese_by_two_moves = [Constants.MOVES.SCREECH]
	
	func test_lowers_defenese_by_two(params = use_parameters(lower_defenese_by_two_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 100)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, -2)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestIncreasesEvasionByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var increase_evasion_by_one_moves = [Constants.MOVES.DOUBLE_TEAM]
	
	func test_increases_evasion_by_one(params = use_parameters(increase_evasion_by_one_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 1)
		

class TestHeals50Percent extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var heals_50_percent_moves = [Constants.MOVES.RECOVER, Constants.MOVES.SOFT_BOILED]
	
	func test_user_heals_50_percent(params = use_parameters(heals_50_percent_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 50)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		charizard.current_hp -= int(charizard.current_hp * 0.75)
		var hp = charizard.current_hp
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_almost_eq(charizard.current_hp, hp + int(charizard.stats.hp * 0.5), 4)


class TestMinimize extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_increases_evasion_by_two():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.MINIMIZE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 2)
		assert_has(battle.player_team[0].battler_flags, "minimize")


class TestDefenseCurl extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_increases_defense_by_one():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.DEFENSE_CURL)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 1)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
		assert_has(battle.player_team[0].battler_flags, "defense_curl")


class TestIncreasesDefenseByTwo extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var increase_defense_by_two_moves = [Constants.MOVES.BARRIER, Constants.MOVES.ACID_ARMOR]
	
	func test_increases_defense_by_two(params = use_parameters(increase_defense_by_two_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 2)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestScreenMoves extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var screen_moves = [[Constants.MOVES.LIGHT_SCREEN, "light_screen", Constants.MOVES.ACID, 16], [Constants.MOVES.REFLECT, "reflect", Constants.MOVES.TACKLE, 10]]
	
	func test_moves_deal_normal_damage(params = use_parameters(screen_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[2])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_does_not_have(battle.player_team[0].side.side_flags, params[1])
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - params[3])
		
	func test_moves_deal_half_damage(params = use_parameters(screen_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(params[2]), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.player_team[0].side.side_flags, params[1])
		assert_eq(battle.player_team[0].side.side_flags[params[1]][3], 4) # Duration: 5 minus the turn that just passed
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - (params[3] / 2))


class TestHaze extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_resets_all_stat_changes():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.HAZE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.player_team[0].stat_stages.attack = 3
		battle.opponent_team[0].stat_stages.defense = 2
		battle.opponent_team[0].stat_stages.evasion = 5
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestFocusEnergy extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_move_is_not_a_critical_hit():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.FOCUS_ENERGY)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 2) # Crit ratio
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.player_team[0].battler_flags, "focused")
		stub(battle, "run_battle_event").to_do_nothing()
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 10)
		
	func test_move_is_a_critical_hit():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.FOCUS_ENERGY)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(2).when_passed(1, 2) # Crit ratio
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.player_team[0].battler_flags, "focused")
		stub(battle, "run_battle_event").to_do_nothing()
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 15)


class TestSkullBash extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_increases_defense_by_one():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.SKULL_BASH)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "twoturnmove")
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 1)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_does_not_have(battle.player_team[0].battler_flags, "twoturnmove")
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 1)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestIncreasesSpecialDefenseByOne extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var increase_special_defense_by_two_moves = [Constants.MOVES.AMNESIA]
	
	func test_increases_special_defense_by_two(params = use_parameters(increase_special_defense_by_two_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 2)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestDreamEater extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_fails_against_awake_opponent():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 30)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.DREAM_EATER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		charizard.current_hp -= 20
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - 20)
		
	func test_heals_from_damage_dealt_to_asleep_opponent():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 30)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 30)
		var move = Constants.get_move_by_id(Constants.MOVES.DREAM_EATER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		venusaur.status = Constants.get_status_by_id(Constants.STATUSES.SLEEP)
		charizard.current_hp -= 30
		var hp = charizard.current_hp
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(85).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 54)
		assert_eq(battle.player_team[0].pokemon.current_hp, hp + 27)
		
		
class TestSkyAttack extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_flinches_opponent():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(Constants.MOVES.SKY_ATTACK)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "twoturnmove")
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_has(battle.opponent_team[0].battler_flags, "flinch")
		assert_does_not_have(battle.player_team[0].battler_flags, "twoturnmove")

	func test_does_not_flinch_opponent():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(Constants.MOVES.SKY_ATTACK)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "twoturnmove")
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_does_not_have(battle.player_team[0].battler_flags, "twoturnmove")
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")


class TestPsywave extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_move_deals_fixed_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.PSYWAVE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(0).when_passed(0, 100) # Damage calc
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 10)
	
	func test_move_deals_one_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 1)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.PSYWAVE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(0).when_passed(0, 100) # Damage calc
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 1)


class TestSplash extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_move_does_nothing():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.SPLASH)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].battler_flags.is_empty())
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)


class TestRest extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_user_falls_asleep_and_heals_to_full():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 30)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.REST)
		
		charizard.current_hp -= 40
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_has(battle.player_team[0].battler_flags, "sleep")
		assert_eq(battle.player_team[0].battler_flags["sleep"], 3) # Duration
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.SLEEP)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		
	func test_move_fails_if_already_max_hp():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 30)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.REST)

		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


class TestTriAttack extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_inflicts_one_of_three_statuses():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(Constants.MOVES.TRI_ATTACK)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_true(battle.opponent_team[0].pokemon.status.id in [Constants.STATUSES.BURN, Constants.STATUSES.FREEZE, Constants.STATUSES.PARALYSIS])


	func test_does_not_inflicts_one_of_three_statuses():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(Constants.MOVES.TRI_ATTACK)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestSuperFang extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_move_deals_damage_half_of_opponent_current_hp():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.SUPER_FANG)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp / 2)
	
	func test_move_deals_one_damage():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 1)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.PSYWAVE)
		
		venusaur.current_hp = 1
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		#await wait_for_signal(battle.turn_ended, 5)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, 0)


class TestMindReader extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_move_does_not_hit_semi_invulnerable_target():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 80)
		var move = Constants.get_move_by_id(Constants.MOVES.TACKLE) #Any move
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.FLY), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_has(battle.opponent_team[0].battler_flags, "twoturnmove")
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	func test_move_hits_semi_invulnerable_target():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 80)
		var move = Constants.get_move_by_id(Constants.MOVES.MIND_READER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_does_not_have(battle.opponent_team[0].battler_flags, "twoturnmove")
		assert_has(battle.player_team[0].battler_flags, "locked_on")
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.FLY), battle.opponent_team[0], battle.player_team[0])
		battle._play_turn()
		assert_has(battle.opponent_team[0].battler_flags, "twoturnmove")
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


class TestNightmare extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_move_does_not_affect_awake_foes():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.NIGHTMARE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	func test_move_affects_asleep_foes():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.NIGHTMARE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		battle.opponent_team[0].set_status(Constants.STATUSES.SLEEP)
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		var max_hp: int = battle.opponent_team[0].pokemon.stats.hp
		assert_eq(battle.opponent_team[0].pokemon.current_hp, max_hp - max_hp / 4)


class TestSnore extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_fails_if_user_is_awake():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.SNORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	func test_hits_if_user_is_asleep():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.SNORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.SLEEP)
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	func test_flinches_opponent():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.SNORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.SLEEP)
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")


	func test_does_not_flinch_opponent():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.SNORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.player_team[0].set_status(Constants.STATUSES.SLEEP)
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance + 1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_not_same(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_does_not_have(battle.opponent_team[0].battler_flags, "flinch")


class TestCurse extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_curses_foe_when_used_by_ghost_type():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		var move = Constants.get_move_by_id(Constants.MOVES.CURSE)
		
		charizard.species.types.append(Constants.get_type_by_id(Constants.TYPES.GHOST))
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_has(battle.opponent_team[0].battler_flags, "curse")
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - battle.player_team[0].pokemon.stats.hp / 2)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - battle.opponent_team[0].pokemon.stats.hp / 4)
		charizard.species.types.pop_back()


	func test_modifies_stats_when_used_by_non_ghost_type():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(Constants.MOVES.CURSE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_does_not_have(battle.opponent_team[0].battler_flags, "curse")
		assert_eq(battle.player_team[0].stat_stages.attack, 1)
		assert_eq(battle.player_team[0].stat_stages.defense, 1)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, -1)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


class TestUserHPBasePower extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var hp_ratio_base_power = [[100.0, 5, 2], [32.99, 9, 4], [16.99, 16, 8], [9.99, 19, 9], [4.99, 28, 14], [1.99, 37, 18]]
	
	func test_damage_varies_by_user_hp(params = use_parameters(hp_ratio_base_power)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 30)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		var moves: Array[Constants.MOVES] = [Constants.MOVES.FLAIL, Constants.MOVES.REVERSAL]
		var move_index: int = [0, 1].pick_random()
		var move = Constants.get_move_by_id(moves[move_index])
		
		charizard.current_hp = params[0] * charizard.stats.hp / 48
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		var expected_hp = battle.opponent_team[0].pokemon.stats.hp - params[move_index+1]
		assert_eq(battle.opponent_team[0].pokemon.current_hp, expected_hp)


class TestBellyDrum extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var stat_stages = [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
	
	func test_maximizes_attack(params = use_parameters(stat_stages)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.BELLY_DRUM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		battle.player_team[0].stat_stages.attack = params
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.player_team[0].stat_stages.attack, 6)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp / 2)


	func test_fails_if_not_enough_hp():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.BELLY_DRUM)
		
		charizard.current_hp = charizard.stats.hp / 2
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


	func test_fails_if_attack_already_maxed():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var move = Constants.get_move_by_id(Constants.MOVES.BELLY_DRUM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		battle.player_team[0].stat_stages.attack = 6
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.player_team[0].stat_stages.attack, 6)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		
