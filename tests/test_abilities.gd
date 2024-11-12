extends GutTest

class TestSpeedBoost extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_increases_speed_by_one():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SPEED_BOOST)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 1)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)


	func test_does_not_activate_on_switched_turn():
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SPEED_BOOST)
		
		battle = partial_double(Battle).new([blastoise, charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_switch(battle.player_team[0], battle.player_team[1])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
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
		assert_eq(battle.player_team[1].stat_stages.attack, 0)
		assert_eq(battle.player_team[1].stat_stages.defense, 0)
		assert_eq(battle.player_team[1].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[1].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[1].stat_stages.speed, 0)
		assert_eq(battle.player_team[1].stat_stages.hp, 0)
		assert_eq(battle.player_team[1].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[1].stat_stages.evasion, 0)


class TestPreventCriticalHits extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var abilities = [Constants.ABILITIES.BATTLE_ARMOR, Constants.ABILITIES.SHELL_ARMOR]
	
	func test_prevents_opponent_critical_hits(params = use_parameters(abilities)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(24).when_passed(1, 24) # Crit chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - 5) # Crit would be 7


class TestSturdy extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_survives_with_1_hp():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.STURDY)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.WATER_GUN), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, 1)
		
	func test_unaffected_by_ohko_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 75)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.STURDY)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.GUILLOTINE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		

class TestDamp extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var explosion_moves = [Constants.MOVES.EXPLOSION, Constants.MOVES.SELF_DESTRUCT]
		
	func test_prevents_opponent_using_explosion_moves(params = use_parameters(explosion_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.DAMP)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
	
	
	func test_prevents_any_battler_using_explosion_moves(params = use_parameters(explosion_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 50)
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE, 50)
		var bulbasaur: Pokemon = Pokemon.new(Constants.SPECIES.BULBASAUR, 50)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.DAMP)
		
		battle = partial_double(Battle).new([charizard, bulbasaur] as Array[Pokemon], [venusaur, blastoise] as Array[Pokemon])
		
		 # Battler with the ability isn't the user nor the target of the explosion move
		battle.queue_move(Constants.get_move_by_id(params), battle.player_team[0], battle.opponent_team[1])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_eq(battle.player_team[1].pokemon.current_hp, battle.player_team[1].pokemon.stats.hp)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_eq(battle.opponent_team[1].pokemon.current_hp, battle.opponent_team[1].pokemon.stats.hp)
		
	## TODO: Test interaction with Aftermath


class TestLimber extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_prevents_paralysis():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.LIMBER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.THUNDER_WAVE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Test cure paralysis

class TestStatic extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var static_chance = [[29, Constants.STATUSES.PARALYSIS], [30, Constants.STATUSES.NONE]]
	
	func test_chance_to_paralyze_on_contact(params = use_parameters(static_chance)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.STATIC)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(params[0]).when_passed(100) # Static chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, params[1])
		
	func test_does_not_paralyze_on_no_contact_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.STATIC)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(1).when_passed(100) # Static chance - shouldn't get called
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Test paralyzes_ground_type_battler and does_not_paralyze_electric_type_battler


class TestVoltAbsorb extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_heals_when_hit_by_electric_move():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 15)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.VOLT_ABSORB)
		
		charizard.current_hp -= 20
		var hp = charizard.current_hp
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.THUNDER_WAVE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, hp + int(battle.player_team[0].pokemon.stats.hp / 4))


class TestWaterAbsorb extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_heals_when_hit_by_water_move():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 15)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.WATER_ABSORB)
		
		charizard.current_hp -= 20
		var hp = charizard.current_hp
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, hp + int(battle.player_team[0].pokemon.stats.hp / 4))


class TestCompoundEyes extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_increases_move_accuracy():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.COMPOUND_EYES)

		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.HYPNOSIS), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(77).when_passed(1, 100) # For Hypnosis, anything above 60 wouldn't normally work
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.SLEEP)

	func test_does_not_affect_ohko_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.COMPOUND_EYES)

		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.GUILLOTINE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(31).when_passed(1, 100) # For OHKO moves, anything above 30 wouldn't work (same level battlers)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


class TestPreventSleep extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var abilities = [Constants.ABILITIES.INSOMNIA, Constants.ABILITIES.VITAL_SPIRIT]
		
	func test_prevents_sleep_status(params = use_parameters(abilities)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(params)
		
		charizard.current_hp -= 10
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.REST), battle.player_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Test cure sleep


class TestImmunity extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var poison_statuses = [Constants.MOVES.POISON_GAS, Constants.MOVES.TOXIC]
		
	func test_prevents_poison_status(params = use_parameters(poison_statuses)):
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.IMMUNITY)
		
		battle = partial_double(Battle).new([venusaur] as Array[Pokemon], [charizard] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Test cure poison


class TestFlashFire extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_user_is_immune_to_fire_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.FLASH_FIRE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.EMBER), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.opponent_team[0].battler_flags, "flash_fire")
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
	
	# Normally: Fire Punch = 5, Ember = 3, Tackle = 7 (not boosted)
	var moves = [[Constants.MOVES.FIRE_PUNCH, 7], [Constants.MOVES.EMBER, 5], [Constants.MOVES.TACKLE, 7]]
		
	func test_user_attack_is_increased_when_using_fire_move(params = use_parameters(moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.FLASH_FIRE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.EMBER), battle.player_team[0], battle.opponent_team[0])
		battle.queue_move(Constants.get_move_by_id(params[0]), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.opponent_team[0].battler_flags, "flash_fire")
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - params[1])


class TestRoughSkin extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_damages_user_on_contact():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.ROUGH_SKIN)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - int(battle.opponent_team[0].pokemon.stats.hp / 8))
		
	func test_does_not_damage_on_no_contact_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.ROUGH_SKIN)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


class TestWonderGuard extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var non_super_effective_moves = [Constants.MOVES.TACKLE, Constants.MOVES.NIGHT_SHADE, Constants.MOVES.GUILLOTINE]
	
	func test_immune_to_non_super_effective_moves(params = use_parameters(non_super_effective_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 75)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.WONDER_GUARD)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
	
	
	var super_effective_moves = [Constants.MOVES.BUBBLE, Constants.MOVES.THUNDERBOLT]

	func test_vulnerable_to_super_effective_moves(params = use_parameters(super_effective_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.WONDER_GUARD)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_not_same(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)


	func test_vulnerable_to_status_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.WONDER_GUARD)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TAIL_WHIP), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].stat_stages.defense, -1)


class TestLevitate extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var ground_moves = [Constants.MOVES.EARTHQUAKE, Constants.MOVES.FISSURE]
	
	func test_immune_to_ground_damaging_moves(params = use_parameters(ground_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.LEVITATE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	func test_not_immune_to_ground_status_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.LEVITATE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SAND_ATTACK), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		assert_eq(battle.opponent_team[0].stat_stages.accuracy, -1)
		assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)
		
	## TODO: Test against hazards, Thousand Arrows and Gravity/Iron Ball etc.
	

class TestEffectSpore extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var ground_moves = [[10, Constants.STATUSES.SLEEP], [20, Constants.STATUSES.PARALYSIS], [29, Constants.STATUSES.POISON]]
	
	func test_30_percent_chance_to_inflict_status_on_contact(params = use_parameters(ground_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.EFFECT_SPORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(params[0]).when_passed(100) # Activation chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, params[1])


	func test_does_not_activate_on_no_contact_move():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.EFFECT_SPORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(0).when_passed(100) # Activation chance (shouldn't get called)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		
	func test_does_not_activate_on_grass_types():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.EFFECT_SPORE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(0).when_passed(100) # Activation chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Uncomment when Overcoat is implemented
	#func test_does_not_activate_on_battler_with_overcoat():
		#var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		#var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		#venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.EFFECT_SPORE)
		#charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.OVERCOAT)
		#
		#battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		#
		#battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		#
		#stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		#stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		#stub(battle, "random").to_return(0).when_passed(100) # Activation chance
		#stub(battle, "run_battle_event").to_do_nothing()

		#battle._play_turn()
		#
		#assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestPreventStatLowering extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var abilities = [Constants.ABILITIES.CLEAR_BODY, Constants.ABILITIES.WHITE_SMOKE]
	
	func test_prevents_stat_lowering_from_opponent(params = use_parameters(abilities)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(params)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TAIL_WHIP), battle.opponent_team[0], battle.player_team[0])
		
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

	## TODO: Uncomment when a self stat lowering move is implemented
	#func test_does_not_prevent_self_stat_lowering():
		#var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		#var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		#charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.CLEAR_BODY)
		#
		#battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		#
		#battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SHELL_SMASH), battle.opponent_team[0], battle.player_team[0])
		#
		#stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		#stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		#stub(battle, "run_battle_event").to_do_nothing()

		#battle._play_turn()
		#
		#assert_eq(battle.opponent_team[0].stat_stages.attack, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.defense, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.special_attack, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.special_defense, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.speed, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.hp, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.accuracy, 0)
		#assert_eq(battle.opponent_team[0].stat_stages.evasion, 0)
		
	## TODO: Moves that affect stats directly
	
	
class TestLightningRod extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var electric_moves = [Constants.MOVES.THUNDER, Constants.MOVES.THUNDER_PUNCH]
	
	func test_increases_special_attack_when_hit_with_electric_move(params = use_parameters(electric_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.LIGHTNING_ROD)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 1)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)

	## TODO: Test redirection, accuracy bypass by electric moves


class TestSereneGrace extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_doubles_move_effect_chance():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		var move = Constants.get_move_by_id(Constants.MOVES.FIRE_PUNCH)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SERENE_GRACE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(move.effect_chance * 2).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.BURN)

	## TODO: Test interaction with King's Rock/Razor Fang


class TestHugePower extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_doubles_user_attack():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.HUGE_POWER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 11) # Normally -6
		
	func test_does_not_double_user_special_attack():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.HUGE_POWER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 3)


class TestPoisonPoint extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var poison_chance = [[29, Constants.STATUSES.POISON], [30, Constants.STATUSES.NONE]]
	
	func test_chance_to_poison_on_contact(params = use_parameters(poison_chance)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.POISON_POINT)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(params[0]).when_passed(100) # Poison Point chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, params[1])
		
		
	func test_does_not_poison_on_no_contact_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.POISON_POINT)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(1).when_passed(100) # Poison Point chance - shouldn't get called
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestMagmaArmor extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_prevents_freeze_status():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 30)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.MAGMA_ARMOR)
		
		charizard.current_hp -= 10
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.ICE_PUNCH), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy and chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Test cure freeze


class TestWaterVeil extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	func test_prevents_burn_status():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 30)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.WATER_VEIL)
		
		charizard.current_hp -= 10
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.FIRE_PUNCH), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy and chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)

	## TODO: Test cure burn
	
	
class TestSoundproof extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var sound_moves = [Constants.MOVES.GROWL, Constants.MOVES.ROAR, Constants.MOVES.SING, Constants.MOVES.SUPERSONIC, Constants.MOVES.SCREECH]
	
	func test_immune_to_sound_moves(params = use_parameters(sound_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE) # For Roar
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SOUNDPROOF)
		
		battle = partial_double(Battle).new([charizard, blastoise] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon, charizard)
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp)
		assert_true(battle.player_team[0].battler_flags.is_empty())
		assert_eq(battle.player_team[0].stat_stages.attack, 0)
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, 0)
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
	
	## TODO: Test not immune to own sound based moves


class TestThickFat extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Normally: 17, 22, 8, 11
	var halved_moves = [[Constants.MOVES.ICE_PUNCH, 9], [Constants.MOVES.ICE_BEAM, 12], [Constants.MOVES.FIRE_PUNCH, 4], [Constants.MOVES.FLAMETHROWER, 6]]
	
	func test_halves_opponent_attack_when_hit_with_ice_or_fire_move(params = use_parameters(halved_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.THICK_FAT)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params[0]), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - params[1])
	
	var non_halved_moves = [[Constants.MOVES.TACKLE, 10], [Constants.MOVES.BUBBLE, 22]]
	
	func test_does_not_halve_opponent_attack_when_hit_with_other_moves(params = use_parameters(non_halved_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.THICK_FAT)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params[0]), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - params[1])


class TestFlameBody extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var burn_chance = [[29, Constants.STATUSES.BURN], [30, Constants.STATUSES.NONE]]
	
	func test_chance_to_burn_on_contact(params = use_parameters(burn_chance)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.FLAME_BODY)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(params[0]).when_passed(100) # Flame Body chance
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, params[1])
		
		
	func test_does_not_burn_on_no_contact_moves():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.FLAME_BODY)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.BUBBLE), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(1).when_passed(100) # Flame Body chance - shouldn't get called
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)


class TestKeenEye extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
		
	var lower_accuracy_moves = [Constants.MOVES.SAND_ATTACK, Constants.MOVES.SMOKESCREEN, Constants.MOVES.KINESIS, Constants.MOVES.FLASH]
	
	func test_prevents_accuracy_lowering_from_opponent(params = use_parameters(lower_accuracy_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.KEEN_EYE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params), battle.player_team[0], battle.opponent_team[0])
		
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

	## TODO: Test ignore evasion
	
	
class TestHyperCutter extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Using accuracy as control that it only prevents attack from being lowered
	var lowering_stat_moves = [[Constants.MOVES.GROWL, 0], [Constants.MOVES.SMOKESCREEN, -1]]
	
	func test_prevents_attack_lowering_from_opponent(params = use_parameters(lowering_stat_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.HYPER_CUTTER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params[0]), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].stat_stages.attack, 0) # Not lowered
		assert_eq(battle.player_team[0].stat_stages.defense, 0)
		assert_eq(battle.player_team[0].stat_stages.special_attack, 0)
		assert_eq(battle.player_team[0].stat_stages.special_defense, 0)
		assert_eq(battle.player_team[0].stat_stages.speed, 0)
		assert_eq(battle.player_team[0].stat_stages.hp, 0)
		assert_eq(battle.player_team[0].stat_stages.accuracy, params[1])
		assert_eq(battle.player_team[0].stat_stages.evasion, 0)
		
	## TODO: Moves that affect stats directly


class TestTruant extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	func test_loafs_around_every_2_turns():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.TRUANT)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "truant")
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)
		
		var hp = battle.opponent_team[0].pokemon.current_hp
		stub(battle, "run_battle_event").to_do_nothing()
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		battle._play_turn()
		
		assert_does_not_have(battle.player_team[0].battler_flags, "truant")
		assert_eq(battle.opponent_team[0].pokemon.current_hp, hp)


	func test_two_turn_moves_do_not_fully_execute():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.TRUANT)
				
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.FLY), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_has(battle.player_team[0].battler_flags, "twoturnmove")
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_does_not_have(battle.player_team[0].battler_flags, "twoturnmove")
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


	func test_recharge_and_loafing_happen_on_same_turn():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 100)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.TRUANT)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.HYPER_BEAM), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100)
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()

		assert_has(battle.player_team[0].battler_flags, "recharge")
		assert_has(battle.player_team[0].battler_flags, "truant")
		var hp = battle.opponent_team[0].pokemon.current_hp
		assert_not_same(hp, battle.opponent_team[0].pokemon.stats.hp) # Opponent was hurt
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		battle.player_team[0].side.current_battler_index = 0 # Need a better way to do this
		battle._change_state(Battle.STATE.COMMAND_PHASE)
		await wait_seconds(1)
		assert_does_not_have(battle.player_team[0].battler_flags, "recharge")
		assert_does_not_have(battle.player_team[0].battler_flags, "truant")
		assert_eq(hp, battle.opponent_team[0].pokemon.current_hp) # Opponent's HP didn't change because user was recharging

	## TODO: Test interaction with Instruct
	
class TestHustle extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	## Tackle would normally do 6, Gust is not affected by the ability
	var moves = [[Constants.MOVES.TACKLE, 9], [Constants.MOVES.GUST, 18]]
	
	func test_increases_user_attack_by_50_percent(params = use_parameters(moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.HUSTLE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(params[0]), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


	func test_lowers_physical_attacks_accuracy():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.HUSTLE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(81).when_passed(1, 100) # Accuracy - will miss
		
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)

	func test_does_not_lower_special_attacks_accuracy():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.HUSTLE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.GUST), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(81).when_passed(1, 100) # Accuracy - will hit, not lowered
		
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_not_same(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp)


class TestShedSkin extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var statuses = [Constants.STATUSES.BAD_POISON, Constants.STATUSES.BURN, Constants.STATUSES.PARALYSIS, Constants.STATUSES.FREEZE, Constants.STATUSES.POISON, Constants.STATUSES.SLEEP]
	
	func test_chance_to_cure_status(params = use_parameters(statuses)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR)
		charizard.status = Constants.get_status_by_id(params)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SHED_SKIN)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(32).when_passed(100) # Shed Skin chance
		stub(battle, "run_battle_event").to_do_nothing()
		battle.player_team[0].set_status(params, true, true) # Use function to set flags

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		## TODO: Priority. It activates before the statuses
		
	func test_does_not_cure_status(params = use_parameters(statuses)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.SHED_SKIN)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.SPLASH), battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random").to_return(33).when_passed(100) # Shed Skin chance
		stub(battle, "run_battle_event").to_do_nothing()
		battle.player_team[0].set_status(params, true, true) # Use function to set flags

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, params)


class TestGuts extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var statuses = [Constants.STATUSES.BAD_POISON, Constants.STATUSES.BURN, Constants.STATUSES.PARALYSIS, Constants.STATUSES.POISON]
	
	func test_increases_attack_by_50_percent_if_user_has_status(params = use_parameters(statuses)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.GUTS)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random").to_return(100).when_passed(100) # For Paralysis
		stub(battle, "run_battle_event").to_do_nothing()
		battle.player_team[0].set_status(params, true, true) # Use function to set flags		

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, params)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 9) # Normally would be 6


	func test_does_not_increase_attack_if_user_has_no_status():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.GUTS)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 6)


	func test_does_not_increase_special_attack(params = use_parameters(statuses)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.GUTS)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.GUST), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random").to_return(100).when_passed(100) # For Paralysis
		stub(battle, "run_battle_event").to_do_nothing()
		battle.player_team[0].set_status(params, true, true) # Use function to set flags

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.status.id, params)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 18)


class TestMarvelScale extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	var statuses = [Constants.STATUSES.BAD_POISON, Constants.STATUSES.BURN, Constants.STATUSES.PARALYSIS, Constants.STATUSES.POISON, Constants.STATUSES.FREEZE, Constants.STATUSES.SLEEP]
	
	func test_increases_defense_by_50_percent_if_target_has_status(params = use_parameters(statuses)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.MARVEL_SCALE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()
		battle.opponent_team[0].set_status(params, true, true) # Use function to set flags

		battle._play_turn()
		
		await wait_seconds(1)
		assert_eq(battle.opponent_team[0].pokemon.status.id, params)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 7) # Normally would be 10


	func test_does_not_increase_defense_if_target_has_no_status():
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.MARVEL_SCALE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.TACKLE), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.status.id, Constants.STATUSES.NONE)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 6)


	func test_does_not_increase_special_defense(params = use_parameters(statuses)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 10)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.MARVEL_SCALE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(Constants.get_move_by_id(Constants.MOVES.GUST), battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.END_TURN_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "random").to_return(100).when_passed(100) # For Paralysis
		stub(battle, "run_battle_event").to_do_nothing()
		battle.opponent_team[0].set_status(params, true, true) # Use function to set flags

		battle._play_turn()
		
		await wait_seconds(1)
		assert_eq(battle.opponent_team[0].pokemon.status.id, params)
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - 18)


class TestOvergrow extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	
	var grass_moves = [Constants.MOVES.MEGA_DRAIN, Constants.MOVES.VINE_WHIP]
	
	func test_increases_attack_when_using_grass_move_on_low_hp(params = use_parameters(grass_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params)
		venusaur.current_hp = venusaur.current_hp / 3
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.OVERGROW)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - 9) # Normally would be 6


	func test_does_not_increase_attack_when_not_low_on_hp(params = use_parameters(grass_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params)
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.OVERGROW)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - 6)

	var non_grass_moves = [[Constants.MOVES.TACKLE, 10], [Constants.MOVES.GUST, 11], [Constants.MOVES.BUBBLE, 22], [Constants.MOVES.EMBER, 5]]

	func test_does_not_increase_attack_when_not_using_grass_move(params = use_parameters(non_grass_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		venusaur.current_hp = venusaur.current_hp / 3
		venusaur.ability = Constants.get_ability_by_id(Constants.ABILITIES.OVERGROW)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.opponent_team[0], battle.player_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(20).when_passed(1, 100) # Accuracy - so Ember's burn chance does not activate
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.player_team[0].pokemon.current_hp, battle.player_team[0].pokemon.stats.hp - params[1]) # Normally would be 6


class TestBlaze extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Boosted damage and normal damage
	var fire_moves = [[Constants.MOVES.FIRE_PUNCH, 26, 18], [Constants.MOVES.EMBER, 18, 12]]
	
	func test_increases_attack_when_using_fire_move_on_low_hp(params = use_parameters(fire_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.current_hp = charizard.current_hp / 3
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.BLAZE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(40).when_passed(1, 100) # Accuracy - so burn effects don't activate
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


	func test_does_not_increase_attack_when_not_low_on_hp(params = use_parameters(fire_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 10)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.BLAZE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(40).when_passed(1, 100) # Accuracy - so burn effects don't activate
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[2])

	var non_fire_moves = [[Constants.MOVES.TACKLE, 10], [Constants.MOVES.GUST, 30], [Constants.MOVES.BUBBLE, 5], [Constants.MOVES.VINE_WHIP, 2]]

	func test_does_not_increase_attack_when_not_using_fire_move(params = use_parameters(non_fire_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.current_hp = charizard.current_hp / 3
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.BLAZE)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


class TestTorrent extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Boosted damage and normal damage
	var water_moves = [[Constants.MOVES.BUBBLE_BEAM, 17, 12], [Constants.MOVES.WATERFALL, 24, 16]]
	
	func test_increases_attack_when_using_water_move_on_low_hp(params = use_parameters(water_moves)):
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 15)
		var move = Constants.get_move_by_id(params[0])
		blastoise.current_hp = blastoise.current_hp / 3
		blastoise.ability = Constants.get_ability_by_id(Constants.ABILITIES.TORRENT)
		
		battle = partial_double(Battle).new([blastoise] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


	func test_does_not_increase_attack_when_not_low_on_hp(params = use_parameters(water_moves)):
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 15)
		var move = Constants.get_move_by_id(params[0])
		blastoise.ability = Constants.get_ability_by_id(Constants.ABILITIES.TORRENT)
		
		battle = partial_double(Battle).new([blastoise] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[2])

	var non_water_moves = [[Constants.MOVES.TACKLE, 10], [Constants.MOVES.GUST, 16], [Constants.MOVES.EMBER, 16], [Constants.MOVES.VINE_WHIP, 2]]

	func test_does_not_increase_attack_when_not_using_water_move(params = use_parameters(non_water_moves)):
		var blastoise: Pokemon = Pokemon.new(Constants.SPECIES.BLASTOISE, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		blastoise.current_hp = blastoise.current_hp / 3
		blastoise.ability = Constants.get_ability_by_id(Constants.ABILITIES.TORRENT)
		
		battle = partial_double(Battle).new([blastoise] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(20).when_passed(1, 100) # Accuracy - so ember's burn chance does not activate
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


class TestSwarm extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Boosted damage and normal damage
	var bug_moves = [[Constants.MOVES.LEECH_LIFE, 26, 18]] # TODO: Add special bug move when implemented
	
	func test_increases_attack_when_using_bug_move_on_low_hp(params = use_parameters(bug_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.current_hp = charizard.current_hp / 3
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SWARM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


	func test_does_not_increase_attack_when_not_low_on_hp(params = use_parameters(bug_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SWARM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[2])

	var non_bug_moves = [[Constants.MOVES.TACKLE, 10], [Constants.MOVES.GUST, 30], [Constants.MOVES.BUBBLE, 5], [Constants.MOVES.VINE_WHIP, 2]]

	func test_does_not_increase_attack_when_not_using_bug_move(params = use_parameters(non_bug_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.current_hp = charizard.current_hp / 3
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.SWARM)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])


class TestPurePower extends GutTest:
	var battle = null
	
	func after_each():
		battle = null
	
	# Normally 10 and 2
	var moves = [[Constants.MOVES.TACKLE, 18], [Constants.MOVES.VINE_WHIP, 5]]
	
	func test_doubles_user_attack(params = use_parameters(moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.PURE_POWER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])

	var special_moves = [[Constants.MOVES.BUBBLE, 5], [Constants.MOVES.GUST, 30]]

	func test_does_not_double_user_special_attack(params = use_parameters(special_moves)):
		var charizard: Pokemon = Pokemon.new(Constants.SPECIES.CHARIZARD, 20)
		var venusaur: Pokemon = Pokemon.new(Constants.SPECIES.VENUSAUR, 20)
		var move = Constants.get_move_by_id(params[0])
		charizard.ability = Constants.get_ability_by_id(Constants.ABILITIES.PURE_POWER)
		
		battle = partial_double(Battle).new([charizard] as Array[Pokemon], [venusaur] as Array[Pokemon])
		
		battle.queue_move(move, battle.player_team[0], battle.opponent_team[0])
		
		stub(battle, "_on_state_changed").to_do_nothing().when_passed(Battle.STATE.COMMAND_PHASE)
		stub(battle, "random_range").to_return(1).when_passed(1, 100) # Accuracy
		stub(battle, "random_range").to_return(100).when_passed(85, 100) # Damage calc
		stub(battle, "random_range").to_return(1).when_passed(1, 24) # Crit
		stub(battle, "run_battle_event").to_do_nothing()

		battle._play_turn()
		
		assert_eq(battle.opponent_team[0].pokemon.current_hp, battle.opponent_team[0].pokemon.stats.hp - params[1])
