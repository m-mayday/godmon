class_name StatusHandler
## Base status handler
## Other statuses override the methods they need
## Methods are roughly ordered the way they happen in battle

static var statuses: Dictionary = {
	Constants.STATUSES.BURN: Burn.new,
	Constants.STATUSES.FREEZE: Freeze.new,
	Constants.STATUSES.PARALYSIS: Paralysis.new,
	Constants.STATUSES.POISON: Poison.new,
	Constants.STATUSES.SLEEP: Sleep.new,
	Constants.STATUSES.BAD_POISON: BadPoison.new,
}

## Returns the handler for the status id provided, or the base status handler if it's not found.
static func get_status_handler(p_status: Status) -> StatusHandler:
	return statuses.get(p_status.id, StatusHandler.new).call(p_status)

var status: Status


func _init(p_status: Status):
	status = p_status


## Checks if a battler is immune to the status
func is_battler_immune(battler: Battler) -> bool:
	for type in battler.pokemon.species.types:
		if status.immune_types.has(type.id):
			return true
	return false


## Returns the initial duration of the status
func initial_duration(_battle: Battle, _battler: Battler) -> int:
	return 0


## Subpriority modifier when calculating priority
func on_priority_bracket_change(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> float:
	return 0.0


## Called when calculating speed for battler (i.e.: when calculating priority)
## Speed will be multiplied by the modifier returned by this method
func on_modify_speed(_battle: Battle, _user: Battler, _speed: float) -> float:
	return 1.0


## Called before a move is used
## Returning false means the move shouldn't be used
func on_before_move(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> bool:
	return true


## Called when a damaging hit connects with the target
func on_move_hit(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> void:
	return


## Called when calculating the final damage a move hit will deal
## Damage will be multiplied by the modifier returned by this method
func on_modify_damage(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> float:
	return 1.0


## Called at the end of a turn
func on_residual(_battle: Battle, _pokemon: Battler) -> void:
	return


class Burn extends StatusHandler:
	func on_modify_damage(_battle: Battle, user: Battler, _target: Battler, move: Move) -> float:
		if not user.has_status(Constants.STATUSES.BURN):
			return 1.0
		if move.is_physical() and user.pokemon.ability.id != Constants.ABILITIES.GUTS:
			return 0.5
		return 1.0


	func on_residual(battle: Battle, battler: Battler) -> void:
		print("Burn reduced ", battler.pokemon.name, "'s HP. Current: ", battler.pokemon.current_hp)
		battle.add_battle_event(BattleDialogueEvent.new("{0} is burned!", [battler.pokemon.name]))
		battler.damage(int(battler.pokemon.stats.hp / 16))
		print("HP after burn: ", battler.pokemon.current_hp)


class Freeze extends StatusHandler:
	func on_before_move(battle: Battle, user: Battler, _target: Battler, move: Move) -> bool:
		if move.flags.has(Constants.MOVE_FLAGS.DEFROST) or battle.random(100) < 20:
			user.cure_status()
			return true
		battle.add_battle_event(BattleDialogueEvent.new("{0} is frozen and can't move!", [user.pokemon.name]))
		return false


	func on_move_hit(_battle: Battle, _user: Battler, target: Battler, move: Move) -> void:
		if not move.is_damaging():
			return
		if move.type == Constants.TYPES.FIRE or move.flags.has(Constants.MOVE_FLAGS.DEFROST):
			target.cure_status()


class Paralysis extends StatusHandler:
	func on_modify_speed(_battle: Battle, user: Battler, _speed: float) -> float:
		if user.pokemon.status.id == Constants.STATUSES.PARALYSIS:
			return 0.5
		return 1.0


	func on_before_move(battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		if battle.random(100) < 25:
			battle.add_battle_event(BattleDialogueEvent.new("{0} is paralyzed and can't move!", [user.pokemon.name]))
			return false
		return true


class Poison extends StatusHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		print("Poison reduced ", battler.pokemon.name, "'s HP. Current: ", battler.pokemon.current_hp)
		battle.add_battle_event(BattleDialogueEvent.new("{0} is poisoned!", [battler.pokemon.name]))
		battler.damage(int(battler.pokemon.stats.hp / 8))
		print("HP after poison: ", battler.pokemon.current_hp)


class Sleep extends StatusHandler:
	func initial_duration(battle: Battle, _battler: Battler) -> int:
		return battle.random_range(2, 4)


	func on_before_move(battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		var duration: int = user.battler_flags.get("sleep")
		print("Sleep duration: ", duration)
		duration -= 1
		if duration <= 0:
			user.cure_status() # flag is erased in this function
			return true
		user.battler_flags["sleep"] = duration
		print("Sleep reduced: ", duration)
		battle.add_battle_event(BattleDialogueEvent.new("{0} is asleep and can't move!", [user.pokemon.name]))
		return false


class BadPoison extends StatusHandler:
	func initial_duration(_battle: Battle, _battler: Battler) -> int:
		return 1


	func on_residual(battle: Battle, battler: Battler) -> void:
		var counter = battler.battler_flags.get("bad_poison")
		print("Bad Poison counter: ", counter)
		print("Bad Poison reduced ", battler.pokemon.name, "'s HP. Current: ", battler.pokemon.current_hp)
		battle.add_battle_event(BattleDialogueEvent.new("{0} is poisoned!", [battler.pokemon.name]))
		battler.damage(maxi(1, int(battler.pokemon.stats.hp / 16)) * counter)
		print("HP after poison: ", battler.pokemon.current_hp)
		if counter < 15:
			counter += 1
			battler.battler_flags["bad_poison"] = counter
