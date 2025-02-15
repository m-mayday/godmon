class_name FlagHandler
## Base flag handler
## Other flags override the methods they need
## Methods are roughly ordered the way they happen in battle

static var flags: Dictionary = {
	Constants.FLAGS.BOUND: Bound.new,
	Constants.FLAGS.FLINCH: Flinch.new,
	Constants.FLAGS.LOCKED_MOVE: LockedMove.new,
	Constants.FLAGS.CONFUSION: Confusion.new,
	Constants.FLAGS.RECHARGE: Recharge.new,
	Constants.FLAGS.SEEDED: Seeded.new,
	Constants.FLAGS.RAGE: Rage.new,
	Constants.FLAGS.FOCUSED: Focused.new,
	Constants.FLAGS.MIST: Mist.new,
	Constants.FLAGS.LIGHT_SCREEN: LightScreen.new,
	Constants.FLAGS.REFLECT: Reflect.new,
	Constants.FLAGS.DISABLE: Disable.new,
	Constants.FLAGS.LOCKED_ON: LockedOn.new,
	Constants.FLAGS.NIGHTMARE: Nightmare.new,
	Constants.FLAGS.CURSE: Curse.new,
	Constants.FLAGS.PERISH_SONG: PerishSong.new,
}

## Returns the handler for the flag id provided, or the base flag handler if it's not found.
static func get_flag_handler(flag_id: Constants.FLAGS, battler: Battler) -> FlagHandler:
	return flags.get(flag_id, FlagHandler.new).call(battler)


var owner_battler: Battler
var owner_side: Side

func _init(p_battler: Battler):
	owner_battler = p_battler
	owner_side = p_battler.side

## Called before a move is used
## Returning false means the move shouldn't be used
func on_before_move(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> bool:
	return true


## Called when target is in a semi invulnerable state (Second part of Fly, Dig, etc.)
## Returning false means that invulnerability is bypassed and move execution continues
func on_invulnerability(_battle: Battle, _user: Battler, _target: Battler) -> bool:
	return true


## Called when calculating accuracy for a move
## Returns the new base accuracy
func on_modify_accuracy(_battle: Battle, _user: Battler, _target: Battler, _move: Move, accuracy: int) -> int:
	return accuracy


## Called when calculating if a move should land a critical hit or not
## The returned ratio of this method added to the current ratio
func on_modify_critical_ratio(_battle: Battle, _battler: Battler) -> int:
	return 0


## Called when calculating the final damage a move hit will deal
## Damage will be multiplied by the modifier returned by this method
func on_modify_damage(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> float:
	return 1.0


## Called when a move hits a target (after damage is dealt)
func on_move_hit(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> void:
	return


## Called when a battler is about to change a stat stage
## Returning false means the change should not happen
func on_try_boost(_battle: Battle, _user: Battler, _target: Battler, _boost: Stats) -> bool:
	return true


## Called at the end of a turn
func on_residual(_battle: Battle, _battler: Battler) -> void:
	return


class Bound extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		var bound: Array = battler.battler_flags.get("bound")
		print("Bind duration: ", bound[1])
		battler.battler_flags["bound"] = bound
		print("Bound reduced ", battler.pokemon.name, "'s HP. Current: ", battler.pokemon.current_hp)
		battler.damage(int(battler.pokemon.stats.hp / 8))
		print("HP after bound: ", battler.pokemon.current_hp)
		bound[1] -= 1
		if bound[1] <= 0:
			battle.add_battle_event(BattleDialogueEvent.new("{0} is no longer bound!", [battler.pokemon.name]))
			battler.battler_flags.erase("bound")
			return
		battle.add_battle_event(BattleDialogueEvent.new("{0} was squeezed!", [battler.pokemon.name]))
		print("Bind duration after activation: ", bound[1])


class Flinch extends FlagHandler:
	func on_before_move(battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		battle.add_battle_event(BattleDialogueEvent.new("{0} flinched and couldn't move!", [user.pokemon.name]))
		return false


	func on_residual(_battle: Battle, battler: Battler) -> void:
		battler.battler_flags.erase("flinch")


class LockedMove extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		var locked: Array = battler.battler_flags.get("lockedmove")
		print("Locked move duration: ", locked[3])
		locked[3] -= 1
		print("Locked move reduced: ", locked[3])
		battler.battler_flags["lockedmove"] = locked
		if locked[3] <= 0:
			battle.add_battle_event(BattleDialogueEvent.new("{0} is confused due to fatigue!", [battler.pokemon.name]))
			battler.battler_flags.erase("lockedmove")
			battler.battler_flags["confusion"] = [
				FlagHandler.get_flag_handler(Constants.FLAGS.CONFUSION, battler),
				battle.random_range(1, 4),
			]


class Confusion extends FlagHandler:
	func on_before_move(battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		var confusion: Array = user.battler_flags.get("confusion")
		battle.add_battle_event(BattleDialogueEvent.new("{0} is confused!", [user.pokemon.name]))
		print("Confusion duration: ", confusion[1])
		confusion[1] -= 1
		print("Confusion duration reduced: ", confusion[1])
		if confusion[1] <= 0:
			user.battler_flags.erase("confusion")
			battle.add_battle_event(BattleDialogueEvent.new("{0} snapped out of confusion!", [user.pokemon.name]))
			return true
		user.battler_flags["confusion"] = confusion
		if battle.random(100) < 33:
			return true
		var attack: int = user.get_stat_with_boost('attack');
		var defense: int = user.get_stat_with_boost('defense');
		var random_factor: int = battle.random_range(85, 100)
		# ((((2 * level / 5 + 2) * base_power * attack) / defense) / 50) + 2) * random_factor / 100
		# Base_power is 40 for confusion damage
		var damage := int(int(int(int(int(int(int(2 * user.pokemon.level / 5) + 2) * 40 * int(attack / defense)) / 50) + 2) * random_factor / 100))
		print("Confusion damage[", random_factor, "] = ", damage)
		battle.add_battle_event(BattleDialogueEvent.new("{0} hurt itself in confusion!", [user.pokemon.name]))
		user.damage(damage)
		return false


class Recharge extends FlagHandler:
	func on_before_move(battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		user.battler_flags.erase("recharge")
		user.battler_flags.erase("truant") # In case Truant handler doesn't run
		battle.add_battle_event(BattleDialogueEvent.new("{0} needs to recharge!", [user.pokemon.name]))
		return false


class Seeded extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		if battler.is_fainted():
			battler.battler_flags.erase("seeded")
			return
		var seed_flag: Array = battler.battler_flags.get("seeded")
		var user: Battler = seed_flag[1]
		var battler_to_heal: Battler = user.side.active[seed_flag[2]]
		if battler_to_heal == null or battler_to_heal.is_fainted():
			print("No battler to heal, so seed won't drain HP")
			return
		var damage: int = battler.pokemon.stats.hp / 8
		battler.damage(damage)
		battle.add_battle_event(BattleDialogueEvent.new("{0} lost HP due to seed!", [battler.pokemon.name]))
		battler_to_heal.heal(damage)
		battle.add_battle_event(BattleDialogueEvent.new("{0} recovered HP due to seed!", [battler_to_heal.pokemon.name]))


class Rage extends FlagHandler:
	func on_before_move(_battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		user.battler_flags.erase("rage")
		return true

	func on_move_hit(_battle: Battle, _user: Battler, target: Battler, move: Move) -> void:
		if owner_battler == target and move.is_damaging():
			owner_battler.boost_stat("attack", 1)
			

class Focused extends FlagHandler:
	func on_modify_critical_ratio(_battle: Battle, _battler: Battler) -> int:
		return 2


class Mist extends FlagHandler:
	func on_try_boost(battle: Battle, user: Battler, target: Battler, boost: Stats) -> bool:
		if user == target:
			return true
		if owner_battler == target:
			var mist: Array = target.side.side_flags.get("mist")
			if mist == null:
				return true
			if boost.attack < 0 or boost.special_attack < 0 or boost.defense < 0 or boost.special_defense < 0 or boost.speed < 0 or boost.accuracy < 0 or boost.evasion < 0:
				battle.add_battle_event(BattleDialogueEvent.new("A mist protects {0}", [target.pokemon.name]))
				return false
		return true


	func on_residual(battle: Battle, battler: Battler) -> void:
		var mist: Array = battler.side.side_flags.get("mist")
		if mist == null:
			return
		mist[2] -= 1
		if mist[2] <= 0:
			battler.side.side_flags.erase("mist")
			battle.add_battle_event(BattleDialogueEvent.new("The mist disappeared!"))


class Screen extends FlagHandler:
	func on_modify_damage(_battle: Battle, _user: Battler, target: Battler, move: Move) -> float:
		var screen: Array
		if move.is_special():
			screen = target.side.side_flags.get("light_screen", [])
		elif move.is_physical():
			screen = target.side.side_flags.get("reflect", [])
		if screen.is_empty():
			return 1.0
		if len(target.side.active) > 1:
			return 0.67
		return 0.5


class LightScreen extends Screen:
	func on_residual(battle: Battle, battler: Battler) -> void:
		var screen: Array = battler.side.side_flags.get("light_screen", [])
		if screen.is_empty():
			return
		screen[3] -= 1
		if screen[3] <= 0:
			battler.side.side_flags.erase("light_screen")
			battle.add_battle_event(BattleDialogueEvent.new("Light Screen wore off!"))


class Reflect extends Screen:
	func on_residual(battle: Battle, battler: Battler) -> void:
		var screen: Array = battler.side.side_flags.get("reflect", [])
		if screen.is_empty():
			return
		screen[3] -= 1
		if screen[3] <= 0:
			battler.side.side_flags.erase("reflect")
			battle.add_battle_event(BattleDialogueEvent.new("Reflect wore off!"))


class Disable extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		var disable: Array = battler.battler_flags.get("disable")
		if disable == null:
			return
		disable[2] -= 1
		if disable[2] <= 0:
			battler.side.erase("disable")
			battle.add_battle_event(BattleDialogueEvent.new("Move is no longer disabled!"))


class LockedOn extends FlagHandler:
	func on_invulnerability(_battle: Battle, user: Battler, target: Battler) -> bool:
		var locked_on: Array = user.battler_flags.get("locked_on", [])
		if len(locked_on) > 1:
			var locked_target: Battler = locked_on[1]
			if locked_target == target:
				return false # Bypasses invulnerability
		return true


	func on_modify_accuracy(_battle: Battle, user: Battler, target: Battler, _move: Move, accuracy: int) -> int:
		var locked_on: Array = user.battler_flags.get("locked_on", [])
		if len(locked_on) > 1:
			var locked_target: Battler = locked_on[1]
			if locked_target == target:
				return 0 # Bypasses accuracy checks
		return accuracy


	func on_residual(_battle: Battle, battler: Battler) -> void:
		var locked_on: Array = battler.battler_flags.get("locked_on", [])
		if len(locked_on) > 1:
			var is_active: bool = locked_on[2]
			if is_active:
				battler.battler_flags["locked_on"][2] = false
				return
		battler.battler_flags.erase("locked_on")


class Nightmare extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		if not battler.has_status(Constants.STATUSES.SLEEP):
			battler.battler_flags.erase("nightmare")
			return
		battle.add_battle_event(BattleDialogueEvent.new("{0} is locked in a nightmare!", [battler.pokemon.name]))
		battler.damage(battler.pokemon.stats.hp / 4)


class Curse extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		battle.add_battle_event(BattleDialogueEvent.new("{0} is hurt by CURSE!", [battler.pokemon.name]))
		battler.damage(battler.pokemon.stats.hp / 4)


class PerishSong extends FlagHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		var song: Array = battler.battler_flags.get("perish_song", [])
		song[1] -= 1
		if song[1] <= 0:
			battler.battler_flags.erase("perish_song")
			battler.pokemon.current_hp = 0
			battle.add_battle_event(BattleDialogueEvent.new("{0} fainted due to Perish Song!", [battler.pokemon.name]))
			battle.add_battle_event(HealthChangedEvent.new(battler.pokemon, 0))
			battler.faint()
			return
		battle.add_battle_event(BattleDialogueEvent.new("{0}'s Perish Song count fell to {1}!", [battler.pokemon.name, song[1]]))
		battler.battler_flags["perish_song"] = song
