class_name MoveAction
extends BaseAction
## Handles the logic of a move being used in battle,
## including running move related events, getting targets, dealing damage, etc.

var move: Move ## The move being used
var user: Battler ## The user of the move
var original_target: Battler ## The originally selected target
var battle: Battle ## The current battle
var target_position: int ## The position of the initial target, used to get any other target if necessary
var _current_hit_type_modifier: float ## Type modifier to know if move hit was supereffective or resisted
var _current_hit_critical: bool ## If current move hit was a crit


func _init(p_move: Move, p_user: Battler, p_target: Battler, p_battle: Battle):
	move = p_move
	user = p_user
	original_target = p_target
	battle = p_battle
	if original_target == null:
		original_target = battle.get_oppossite_side(user.side).active[0]
	target_position = -1
	if original_target != null:
		target_position = original_target.side.get_active_battler_position(original_target)


## [Public] Order of action in relation to others.
func get_action_order() -> int:
	return 1


## [Public] The main logic of the move usage
## Runs events, calculates damage, stats, etc.
func execute() -> void:
	if not _step_before_move():
		return
		
	if not move.handler.on_move_locked(battle, user):
		if not move.deduct_pp():
			battle.add_battle_event(BattleDialogueEvent.new("{0} has no PP left!", [user.pokemon.name]))
			return
	
	_step_modify_move()
	
	battle.add_battle_event(BattleDialogueEvent.new("{0} used {1}!", [user.pokemon.name, move.name]))
	
	var targets: Array[Battler] = _get_targets()
	if not _step_try_move(targets):
		return
	
	var failed: Array[Battler] = []
	
	for target in targets:
		if not _step_try_invulnerability(target):
			failed.push_back(target)
			continue
		
		var failed_so_far: int = len(failed)
		var try_hit: Array = battle.run_action_event("try_hit", target, user, [battle, user, target, move])
		for result in try_hit:
			if not result:
				failed.push_back(target)
				break
				
		if len(failed) > failed_so_far:
			continue # It failed on try_hit for the current target, so continue to the next target
				
		# TODO: Immunity step
			
		if not _step_accuracy_check(target):
			failed.push_back(target)
			continue
			
		# TODO: Break protect step (if necessary)
		# TODO: Steal boosts step (if necessary)
			
		if move.is_damaging():
			var number_of_hits: int = move.handler.number_of_hits(battle)
			for hit in number_of_hits:
				# TODO: move.try_hit
				# TODO: Try primary hit (event)
				
				var damage: int = _step_calculate_damage(target, len(targets) > 1)
				
				if _current_hit_type_modifier <= 0.0:
					battle.add_battle_event(BattleDialogueEvent.new("{0} doesn't affect {1}!", [move.name, target.pokemon.name]))
					continue
				
				if damage <= 0:
					failed.push_back(target)
					continue
				
				_deal_damage(damage, target)
				if _current_hit_type_modifier >= 2.0:
					battle.add_battle_event(BattleDialogueEvent.new("It's supereffective!"))
				elif _current_hit_type_modifier < 1.0:
					battle.add_battle_event(BattleDialogueEvent.new("It's not very effective..."))
	
				if _current_hit_critical:
					battle.add_battle_event(BattleDialogueEvent.new("It's a critical hit!"))
					
				move.handler.on_move_hit(battle, user, target)
				battle.run_action_event("move_hit", target, user, [battle, user, target, move])
				
				## TODO: Modify secondaries (event)
				move.handler.on_secondary_effect(battle, user, target)
				
				## TODO: repurpose this event
				battle.run_action_event("secondary_effect", target, null, [battle, user, target])
				
				move.handler.on_recoil(battle, user, damage)
				move.handler.on_drain(battle, user, damage)
		else:
			move.handler.on_move_hit(battle, user, target)

		
		if target.is_fainted():
			target.faint()
			
	if len(failed) != len(targets): # Move hit some targets
		user.last_move_used = move.id
		print("Move failed for targets: ", len(failed))
		if move.flags.has(Constants.MOVE_FLAGS.EXPLOSION) and user.is_fainted():
			user.faint()
	else:
		battle.add_battle_event(BattleDialogueEvent.new("{0} missed!", [user.pokemon.name]))
		move.handler.on_miss(battle, user, original_target)
		

func _step_before_move() -> bool:
	if user.is_fainted() or user.pokemon not in user.side.get_active_pokemon():
		print(user.pokemon.name, " can't act because it fainted or is not active!")
		return false
	print("\n", user.pokemon.name, " wants to use ", move.name, "")
	var before_move: Array = battle.run_action_event("before_move", user, null, [battle, user, original_target, move], true)
	for result in before_move:
		if not result:  # User can't act because of an effect
			move.handler.on_aborted(battle, user, original_target)
			return false
	# TODO: move.handler.before_move
	return true


func _step_modify_move() -> void:
	# TODO: Modify target (event), move.modify_type, move.modify_move, modify type (event)
	battle.run_action_event("modify_move", original_target, user, [battle, user, original_target, move])


func _step_try_move(targets: Array[Battler]) -> bool:
	# User can't act because of an effect, like the charging turn of a move
	if not move.handler.on_try_move(battle, user, original_target):
		return false
	
	for target in targets:
		var try_move: Array = battle.run_action_event("try_move", target, user, [battle, user, target, move], true)
		for result in try_move:
			if not result:
				return false
	
	# TODO: move.try, move.prepare_hit, prepare hit (event)
	return true

func _step_try_invulnerability(target: Battler) -> bool:
	if target.is_semi_invulnerable():
		var invulnerability: Array = battle.run_action_event("invulnerability", target, user, [battle, user, target], true)
		for result in invulnerability:
			if not result:
				return true
		if move.handler.on_invulnerability(battle, user, target):
			battle.add_battle_event(BattleDialogueEvent.new("{0} is semi-invulnerable right now!", [target.pokemon.name]))
			return false
	return true


## [Private] Checks if the move should hit or not
func _step_accuracy_check(target: Battler) -> bool:
	var base_accuracy: int = move.handler.move_accuracy(battle, user, target)
	
	if move.is_ohko() and base_accuracy <= 0:
		return false # Automatically fails
	elif base_accuracy <= 0:
		return true # Always hits
		
	var random_chance: int = battle.random_range(1, 100)
	var results: Array = battle.run_action_event("modify_accuracy", target, user, [battle, user, target, move, base_accuracy])
	for result in results:
		base_accuracy = result
	if base_accuracy <= 0:
		return true # Always hits
	var calculated_accuracy: int = base_accuracy
	if not move.is_ohko():
		# TODO: Modify boost (event)
		var target_stage: int = target.stat_stages.evasion
		var accuracy = user.get_stat_with_boost("accuracy", user.stat_stages.accuracy - target_stage)
		
		# Base accuracy x boosted accuracy x modifiers x micle berry - happiness
		calculated_accuracy = base_accuracy * int(accuracy/100.0 * 1.0 * 1.0) - int(user.pokemon.happiness / 255)
	# TODO: Accuracy (event)
	if calculated_accuracy < random_chance:
		return false
	return true


func _step_calculate_damage(target: Battler, multiple_targets: bool = false) -> int:
	_current_hit_type_modifier = 1.0
	if move.is_ohko():
		return target.pokemon.stats.hp
	
	var fixed_damage: int = move.handler.fixed_damage(battle, user, target)
	if fixed_damage > 0:
		return fixed_damage
		
	var base_power: int = maxi(move.handler.base_power(user, target), 1)
	var is_critical: bool = _is_critical_hit(target)
	# TODO: Base power (event)
	
	var attack_stat: String = user.get_attack_stat(move.category)
	var defense_stat: String = target.get_defense_stat(move.category)
	var calculated_attack_stat: int
	var calculated_defense_stat: int
	
	if is_critical:
		var attack_boost: int = maxi(user.stat_stages[attack_stat], 0)
		var defense_boost: int = maxi(target.stat_stages[defense_stat], 0)
		calculated_attack_stat = user.get_stat_with_boost(attack_stat, attack_boost)
		calculated_defense_stat = target.get_stat_with_boost(defense_stat, defense_boost)
	else:
		calculated_attack_stat = user.get_stat_with_boost(attack_stat)
		calculated_defense_stat = target.get_stat_with_boost(defense_stat)
		
	print("is critical: ", is_critical)
	
	var attack_modifiers: Array = battle.run_action_event("modify_attack", target, user, [battle, user, target, attack_stat, move])
	for result in attack_modifiers:
		calculated_attack_stat *= result
		
	var defense_modifiers: Array = battle.run_action_event("modify_defense", user, target, [battle, user, target, defense_stat, move])
	for result in defense_modifiers:
		calculated_defense_stat *= result
		
	print("calculated attack: ", calculated_attack_stat)
	print("calculated defense: ", calculated_defense_stat)
		
	var base_damage := int(int(int(int(2 * user.pokemon.level / 5 + 2) * base_power * calculated_attack_stat) / calculated_defense_stat) / 50) + 2
	if multiple_targets:
		base_damage = int(base_damage * 0.75)
	
	# TODO: Weather modify damage
	
	if is_critical:
		base_damage = int(base_damage * 1.5)
		
	var random_factor: float = float(battle.random_range(85, 100)) / 100.0
	base_damage = int(base_damage * random_factor)
	
	var stab_modifier: float = _stab_modifier()
	base_damage = int(base_damage * stab_modifier)
	
	var effectiveness_modifier: float = _type_effectiveness_modifier(target)
	_current_hit_type_modifier = effectiveness_modifier
	if effectiveness_modifier == 0:
		return 0
	base_damage = int(base_damage * effectiveness_modifier)
	
	var damage_modifiers: Array = battle.run_action_event("modify_damage", target, user, [battle, user, target, move])
	for modifier in damage_modifiers:
		base_damage = int(base_damage * modifier)
	
	_current_hit_critical = is_critical
	
	return maxi(1, base_damage)


## [Private] Check the type effectiveness of the move on the current target
func _type_effectiveness_modifier(target: Battler) -> float:
	var type_modifier := 1.0
	for target_type in target.pokemon.species.types:
		if target_type.immunities.has(move.type):
			move.handler.on_miss(battle, user, target) # Counts as a miss for Jump Kick
			return 0
		if target_type.weaknesses.has(move.type):
			type_modifier *= 2.0
		elif target_type.resistances.has(move.type):
			type_modifier *= 0.5
			
	## TODO: move.effectiveness, effectiveness (event)
		
	return type_modifier


## [Private] Checks if the move should be a critical hit or not
func _is_critical_hit(target: Battler) -> bool:
	var crit: int = 0
	var critical_chance: Array[int] = [24, 8, 2, 1]
	if move.flags.has(Constants.MOVE_FLAGS.HIGH_CRIT_RATIO):
		crit += 1
	var modifiers: Array = battle.run_action_event("modify_critical_ratio", user, target, [battle, user])
	for modifier in modifiers:
		crit += modifier
	print("Critical hit modifier: ", crit)
	var random_chance: int = battle.random_range(1, critical_chance[crit])
	if random_chance < critical_chance[crit]:
		return false
	var results: Array = battle.run_action_event("critical_hit", target, user, [battle, user, target])
	for result in results:
		if not result:
			return false
	return true


## [Private] Gets the stab modifier (if user is the same type as the move being used)
func _stab_modifier() -> float:
	for type in user.pokemon.species.types:
		if type.id == move.type:
			return 1.5
	return 1.0


## [Private] Runs some damage related events and deals damage to the current target
func _deal_damage(damage: int, target: Battler):
	print("Damage before event: ", damage)
	var results: Array = battle.run_action_event("before_damage", target, user, [battle, user, target, move, damage])
	for result in results:
		damage = mini(result, damage)
	damage = move.handler.on_damage(battle, user, target, damage)
	print("Damage after event: ", damage)
	if not user.is_fainted():
		battle.add_battle_event(AnimationEvent.new("attack_move", [user, target]))
	if move.flags.has(Constants.MOVE_FLAGS.EXPLOSION):
		user.damage(user.pokemon.stats.hp)
	battle.add_battle_event(AnimationEvent.new("on_hit", [target]))
	target.damage(damage)


## [Private] Gets targets depending on the move being used and the type of battle
func _get_targets() -> Array[Battler]:
	var targets: Array[Battler] = []
	match move.handler.move_target():
		Constants.MOVE_TARGET.ALL:
			for side in battle.sides:
				targets = targets + side.active
		Constants.MOVE_TARGET.ALL_ADJACENT:
			if len(user.side.active) > 1:
				targets = user.get_adjacent_allies() 
			targets += user.get_adjacent_foes()
		Constants.MOVE_TARGET.ALL_ADJACENT_FOES:
			targets = user.get_adjacent_foes()
		Constants.MOVE_TARGET.ALL_ALLIES:
			targets = user.side.get_allies(user)
		Constants.MOVE_TARGET.SINGLE_BUT_USER:
			var final_target: Battler = original_target
			if target_position == -1 or original_target.is_fainted():
				var possible_targets: Array[Battler] = []
				for battler in original_target.side.active:
					if not battler.is_fainted():
						possible_targets.append(battler)
				final_target = possible_targets.pick_random()
			targets = [final_target]
		# ALLY_TEAM
		# FIELD
		# FOE_SIDE
		# OTHER
		Constants.MOVE_TARGET.RANDOM_ADJACENT: # An ally is never chosen for this
			targets = [user.get_adjacent_foes().pick_random()]
		Constants.MOVE_TARGET.SINGLE_ADJACENT, Constants.MOVE_TARGET.SINGLE_ADJACENT_FOE:
			var final_target: Battler = original_target
			if target_position == -1:
				final_target = user.get_adjacent_foes().pick_random()
				if final_target == null:
					return []
			final_target = original_target.side.active[target_position]
			if final_target.is_fainted() or not user.is_battler_adjacent(final_target):
				final_target = user.get_adjacent_foes().pick_random()
				if final_target == null:
					return []
			targets = [final_target]
		Constants.MOVE_TARGET.SINGLE_ADJACENT_ALLY:
			if user.side != original_target.side:
				return targets # Shouldn't happen
			var selected_target: Battler = original_target.side.active[target_position]
			if selected_target.is_fainted():
				var new_target: Battler = user.get_adjacent_allies().pick_random()
				return [new_target]
			targets = [selected_target]
		Constants.MOVE_TARGET.USER:
			targets = [user]
		Constants.MOVE_TARGET.OTHER:
			if move.id == Constants.MOVES.CURSE: ## Hardcoded for now, might be ok to keep though
				targets = [user.get_adjacent_foes().pick_random()]
			else:
				targets = [original_target]
		_:
			targets = [original_target] # Use the originally selected target
	return targets
