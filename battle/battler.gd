class_name Battler
extends Resource
## Battler represents a pokemon in a battle.
## It handles related info about the pokemon in battle.

var pokemon: Pokemon ## The pokemon this battle represents
var battle: Battle ## The current battle
var stat_stages: Stats ## Stat stages during battle
var battler_flags: Dictionary ## Different conditions the battler has
var side: Side ## The battler's side in battle
var id: int ## The battler's id. Equal to the pokemon's id
var last_move_used: Constants.MOVES = Constants.MOVES.NONE ## Last move used by the battler in the current battle
var switched_in_this_turn: bool = false ## If this battler was switched in this turn. False means it was already active or was not switched in.

func _init(p_pokemon: Pokemon, p_battle: Battle) -> void:
	pokemon = p_pokemon
	battle = p_battle
	stat_stages = Stats.new()
	stat_stages.accuracy = 0
	stat_stages.evasion = 0
	battler_flags = {}
	id = pokemon.id


## [Public] It increases/decreases the specified stat by the specified amount
## Minimum for a stat is -6 and max is 6
## A battler can be specified to run handlers when trying to boost. Returns true or false if the stat changed or not.
func boost_stat(stat: String, boost: int, battler: Battler = null) -> bool:
	if is_fainted():
		return false
	var stats := Stats.new()
	stats[stat] = boost
	var results = battle.run_action_event("try_boost", self, battler, [battle, battler, self, stats])
	for result in results:
		if !result:
			return false
		
	var stage: int = stat_stages.get(stat)
	if stage == null: return false
	stage += boost
	stat_stages.set(stat, clampi(stage, -6, 6))
	if boost != 0:
		battle.add_battle_event(BattleDialogueEvent.new("{0}'s {1} changed by {2}", [pokemon.name, stat, boost]))
	return true


## [Public] Gets the attack or special attack stat according to the specified move category
func get_attack_stat(move_category: Constants.MOVE_CATEGORY) -> String:
	if move_category == Constants.MOVE_CATEGORY.SPECIAL:
		return "special_attack"
	return "attack"


## [Public] Gets the defense or special defense stat according to the specified move category
func get_defense_stat(move_category: Constants.MOVE_CATEGORY) -> String:
	if move_category == Constants.MOVE_CATEGORY.SPECIAL:
		return "special_defense"
	return "defense"


## [Public] Gets the calculated specified stat (except hp)
## A boost can be specified instead of using the current stat stage (for accuracy/evasion)
func get_stat_with_boost(stat: String, boost: int = -100) -> int:
	if stat == "hp": return pokemon.stats.hp
	var stage: int = boost
	if boost == -100:
		stage = stat_stages.get(stat)
	var base_stat: int = pokemon.stats.get(stat)
	if base_stat == null || stage == null: return 0
	var base_mod: int = 2
	if stat == "accuracy" || stat == "evasion":
		base_mod = 3
	var calculated_stat: int = base_stat
	if stage >= 0:
		calculated_stat = int(base_stat * (base_mod + stage) / base_mod)
	else:
		calculated_stat = int(base_stat * base_mod / (base_mod - stage))
	return calculated_stat


## [Public] Gets the calculated speed with stat stages and other modifiers (ability, item, etc.)
func get_calculated_speed() -> int:
	var speed: float = float(get_stat_with_boost("speed"))
	var results = battle.run_action_event("modify_speed", self, null, [battle, self, speed])
	for result in results:
		speed *= result
	return int(speed)


## [Public] Resets all stat stages to 0
func reset_stat_stages() -> void:
	stat_stages.accuracy = 0
	stat_stages.attack = 0
	stat_stages.defense = 0
	stat_stages.evasion = 0
	stat_stages.special_attack = 0
	stat_stages.special_defense = 0
	stat_stages.speed = 0


## [Public] Tries to set the specified status if possible
## Returns false if the status couldn't be set or true if it was set
func set_status(p_status: Constants.STATUSES, ignore_previous_status: bool = false, ignore_immunity: bool = false) -> bool:
	if not has_status(Constants.STATUSES.NONE) and not ignore_previous_status:
		battle.add_battle_event(BattleDialogueEvent.new("{0} already has a status: {1}!", [pokemon.name, pokemon.status.name]))
		return false
	var new_status = Constants.get_status_by_id(p_status)
	if not ignore_immunity and new_status.handler.is_battler_immune(self):
		battle.add_battle_event(BattleDialogueEvent.new("{0} is immune to {1}!", [pokemon.name, new_status.name]))
		return false
	var results: Array = battle.run_action_event("try_set_status", self, null, [battle, self, p_status])
	for result in results:
		if not result:
			return false
	battle.add_battle_event(BattleDialogueEvent.new("{0} now has status {1}!", [pokemon.name, new_status.name]))
	var duration: int = new_status.handler.initial_duration(battle, self)
	if duration > 0:
		battler_flags[Constants.statuses[new_status.id]] = duration
	pokemon.status = new_status
	battle.add_battle_event(StatusSetEvent.new(pokemon, pokemon.status))
	return true


## [Public] Cures the current status the battler has
func cure_status() -> void:
	if has_status(Constants.STATUSES.NONE):
		return
	battle.add_battle_event(BattleDialogueEvent.new("{0} was cured of its status {1}!", [pokemon.name, pokemon.status.name]))
	battler_flags.erase(Constants.statuses[pokemon.status.id])
	pokemon.status = Constants.get_status_by_id(Constants.STATUSES.NONE)
	battle.add_battle_event(StatusSetEvent.new(pokemon, pokemon.status))
	

## [Public] Indicates if a battler has the specified status
func has_status(status: Constants.STATUSES) -> bool:
	return pokemon.status.id == status


## [Public] Adds battler to the battle's faint queue
func faint() -> void:
	battle.add_battle_event(FaintEvent.new(self))
	battle.faint_queue.push_back(self)
	# TODO: faint (event)
	# TODO: after_faint (event)


## [Public] Substracts damage from the pokemon's current hp
## Adds a HealthChanged event to the battle events
## If hp drops to zero, faint() is called
func damage(p_damage: int) -> void:
	if is_fainted():
		return
	var after_damage_hp: int = maxi(pokemon.current_hp - p_damage, 0)
	battle.add_battle_event(HealthChangedEvent.new(pokemon, after_damage_hp))
	pokemon.current_hp = after_damage_hp


## [Public] Adds hpp to the pokemon's current hp
## Adds a HealthChanged event to the battle events
func heal(hp: int) -> void:
	if is_fainted():
		return
	var after_heal_hp: int = mini(pokemon.stats.hp, pokemon.current_hp + hp)
	battle.add_battle_event(HealthChangedEvent.new(pokemon, after_heal_hp))
	pokemon.current_hp = after_heal_hp


## [Public] Checks if pokemon is in a semi invulnerable state (Fly, Dig, etc.)
func is_semi_invulnerable() -> bool:
	if battler_flags.has("twoturnmove"):
		var move: Move = battler_flags.get("twoturnmove")[2]
		return [Constants.MOVES.FLY, Constants.MOVES.DIG].has(move.id)
	return false


## [Public] Checks if battler can be switched into battle
func can_switch_in(display_message: bool = true) -> bool:
	return side.can_switch_in(self, display_message)


## [Public] Checks if battler can be switched out
func can_switch_out() -> bool:
	var allies: Array[Battler] = side.get_allies(self)
	for ally in allies:
		if ally.can_switch_in(false):
			return true
	return false


## [Public] Returns if the battler is fainted or not
func is_fainted() -> bool:
	return pokemon.current_hp <= 0


## [Public] Returns if the battler can choose an action or not (locked into move, must recharge, etc.)
## If auto_choose is true, the action that prevents battler from choosing is queued.
func can_choose_action(auto_choose: bool = false) -> bool:
	if is_fainted():
		return false
		
	if auto_choose:
		var target: Battler
		var move: Move
		if battler_flags.has("lockedmove"):
			var flag = battler_flags.get("lockedmove")
			target = flag[1]
			move = flag[2]
		elif battler_flags.has("twoturnmove"):
			var flag = battler_flags.get("twoturnmove")
			var user_side = flag[0] as Side
			target = user_side.active[flag[1]]
			move = flag[2]
		elif battler_flags.has("recharge"):
			var flag = battler_flags.get("recharge")
			target = flag[1]
			move = flag[2]
		elif battler_flags.has("gradually_stronger"):
			var flag = battler_flags.get("gradually_stronger")
			target = flag[0]
			move = flag[1]
		else:
			return true
		battle.queue_move(move, self, target)
		return false
	if battler_flags.has("lockedmove") or battler_flags.has("twoturnmove") or battler_flags.has("recharge") or battler_flags.get("gradually_stronger"):
		return false
	return true


## [Public] Gets non-fainted allies that are next to the battler
## Returns the current battler in single battles
func get_adjacent_allies() -> Array[Battler]:
	var adjacent: Array[Battler] = []
	if len(side.active) <= 2: return side.active
	for active in side.active:
		if not active.is_fainted() and is_battler_adjacent(active):
			adjacent.push_back(active)
	return adjacent


## [Public] Gets non-fainted foes that are next to the battler
## Returns the only active foe in single battles
func get_adjacent_foes() -> Array[Battler]:
	var foe_side: Side = battle.get_oppossite_side(side)
	var adjacent: Array[Battler] = []
	if len(side.active) <= 2: return foe_side.active
	for active in foe_side.active:
		if not active.is_fainted() and is_battler_adjacent(active):
			adjacent.push_back(active)
	return adjacent


## [Public] Checks if a battler is adjacent to self
## Returns true if it's adjacent, false otherwise
func is_battler_adjacent(battler: Battler) -> bool:
	# Battler is self, so it's not adjacent
	if self == battler: return false
	
	# Either battler is fainted
	if is_fainted() or battler.is_fainted(): return false
	
	# There are not more than 2 battlers per side, so all battlers are adjacent
	if len(side.active) <= 2 and len(battler.side.active) <= 2: return true

	var self_position: int = side.get_active_battler_position(self)
	var battler_position: int = battler.side.get_active_battler_position(battler)
	# If either battler is not active
	if self_position == -1 or battler_position == -1: return false
	
	return abs(self_position - battler_position) <= 1


## [Public] Gets this battler position (index) on its side/team.
func get_team_position() -> int:
	return side.get_battler_position(self)
