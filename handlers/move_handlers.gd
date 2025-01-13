
class_name MoveHandler
## Base move handler
## Other moves override the methods they need
## Methods are roughly ordered the way they happen in battle

static var moves: Dictionary = {
	Constants.MOVES.DOUBLE_SLAP: MultiStrikeMove.new,
	Constants.MOVES.COMET_PUNCH: MultiStrikeMove.new,
	Constants.MOVES.FIRE_PUNCH: BurnChance.new,
	Constants.MOVES.ICE_PUNCH: FreezeChance.new,
	Constants.MOVES.THUNDER_PUNCH: ParalyzeChance.new,
	Constants.MOVES.GUILLOTINE: OHKOMove.new,
	Constants.MOVES.RAZOR_WIND: RazorWind.new,
	Constants.MOVES.SWORDS_DANCE: SwordsDance.new,
	Constants.MOVES.GUST: Gust.new,
	Constants.MOVES.WHIRLWIND: ForceSwitch.new,
	Constants.MOVES.FLY: Fly.new,
	Constants.MOVES.BIND: TrapTarget.new,
	Constants.MOVES.STOMP: Stomp.new,
	Constants.MOVES.DOUBLE_KICK: TwoHitMove.new,
	Constants.MOVES.JUMP_KICK: CrashDamage.new,
	Constants.MOVES.ROLLING_KICK: FlinchChance.new,
	Constants.MOVES.SAND_ATTACK: LowerAccuracyByOne.new,
	Constants.MOVES.HEADBUTT: FlinchChance.new,
	Constants.MOVES.FURY_ATTACK: MultiStrikeMove.new,
	Constants.MOVES.HORN_DRILL: OHKOMove.new,
	Constants.MOVES.BODY_SLAM: BodySlam.new,
	Constants.MOVES.WRAP: TrapTarget.new,
	Constants.MOVES.TAKE_DOWN: Recoil25Percent.new,
	Constants.MOVES.THRASH: LockingMove.new,
	Constants.MOVES.DOUBLE_EDGE: DoubleEdge.new,
	Constants.MOVES.TAIL_WHIP: LowerDefenseByOne.new,
	Constants.MOVES.POISON_STING: PoisonChance.new,
	Constants.MOVES.TWINEEDLE: Twineedle.new,
	Constants.MOVES.PIN_MISSILE: MultiStrikeMove.new,
	Constants.MOVES.LEER: LowerDefenseByOne.new,
	Constants.MOVES.BITE: FlinchChance.new,
	Constants.MOVES.GROWL: Growl.new,
	Constants.MOVES.ROAR: ForceSwitch.new,
	Constants.MOVES.SING: InflictSleep.new,
	Constants.MOVES.SUPERSONIC: InflictConfusion.new,
	Constants.MOVES.SONIC_BOOM: SonicBoom.new,
	Constants.MOVES.DISABLE: Disable.new,
	Constants.MOVES.ACID: LowerSpecialDefenseByOneChance.new,
	Constants.MOVES.EMBER: BurnChance.new,
	Constants.MOVES.FLAMETHROWER: BurnChance.new,
	Constants.MOVES.MIST: Mist.new,
	Constants.MOVES.ICE_BEAM: FreezeChance.new,
	Constants.MOVES.BLIZZARD: FreezeChance.new, # Will change
	Constants.MOVES.PSYBEAM: ConfuseChance.new,
	Constants.MOVES.BUBBLE_BEAM: LowerSpeedByOneChance.new,
	Constants.MOVES.AURORA_BEAM: AuroraBeam.new,
	Constants.MOVES.HYPER_BEAM: RechargeMove.new,
	Constants.MOVES.SUBMISSION: Recoil25Percent.new,
	Constants.MOVES.LOW_KICK: LowKick.new,
	Constants.MOVES.SEISMIC_TOSS: UserLevelDamage.new,
	Constants.MOVES.ABSORB: Drain50Percent.new,
	Constants.MOVES.MEGA_DRAIN: Drain50Percent.new,
	Constants.MOVES.LEECH_SEED: LeechSeed.new,
	Constants.MOVES.GROWTH: Growth.new,
	Constants.MOVES.SOLAR_BEAM: TwoTurnMove.new,
	Constants.MOVES.POISON_POWDER: InflictPoison.new,
	Constants.MOVES.STUN_SPORE: InflictParalysis.new,
	Constants.MOVES.SLEEP_POWDER: InflictSleep.new,
	Constants.MOVES.PETAL_DANCE: LockingMove.new,
	Constants.MOVES.STRING_SHOT: LowersSpeedByTwo.new,
	Constants.MOVES.DRAGON_RAGE: DragonRage.new,
	Constants.MOVES.FIRE_SPIN: TrapTarget.new,
	Constants.MOVES.THUNDER_SHOCK: ParalyzeChance.new,
	Constants.MOVES.THUNDERBOLT: ParalyzeChance.new,
	Constants.MOVES.THUNDER_WAVE: InflictParalysis.new,
	Constants.MOVES.THUNDER: Thunder.new,
	Constants.MOVES.EARTHQUAKE: Earthquake.new,
	Constants.MOVES.FISSURE: Fissure.new,
	Constants.MOVES.DIG: TwoTurnMove.new,
	Constants.MOVES.TOXIC: Toxic.new,
	Constants.MOVES.CONFUSION: ConfuseChance.new,
	Constants.MOVES.PSYCHIC: LowerSpecialDefenseByOneChance.new,
	Constants.MOVES.HYPNOSIS: InflictSleep.new,
	Constants.MOVES.MEDITATE: IncreaseAttackByOne.new,
	Constants.MOVES.AGILITY: Agility.new,
	Constants.MOVES.RAGE: Rage.new,
	Constants.MOVES.TELEPORT: Teleport.new,
	Constants.MOVES.NIGHT_SHADE: UserLevelDamage.new,
	Constants.MOVES.SCREECH: Screech.new,
	Constants.MOVES.DOUBLE_TEAM: DoubleTeam.new,
	Constants.MOVES.RECOVER: Heal50Percent.new,
	Constants.MOVES.HARDEN: IncreaseDefenseByOne.new,
	Constants.MOVES.MINIMIZE: Minimize.new,
	Constants.MOVES.SMOKESCREEN: LowerAccuracyByOne.new,
	Constants.MOVES.CONFUSE_RAY: InflictConfusion.new,
	Constants.MOVES.WITHDRAW: IncreaseDefenseByOne.new,
	Constants.MOVES.DEFENSE_CURL: DefenseCurl.new,
	Constants.MOVES.BARRIER: IncreaseDefenseByTwo.new,
	Constants.MOVES.LIGHT_SCREEN: Screen.new,
	Constants.MOVES.HAZE: Haze.new,
	Constants.MOVES.REFLECT: Screen.new,
	Constants.MOVES.FOCUS_ENERGY: FocusEnergy.new,
	Constants.MOVES.LICK: ParalyzeChance.new,
	Constants.MOVES.SMOG: PoisonChance.new,
	Constants.MOVES.SLUDGE: PoisonChance.new,
	Constants.MOVES.BONE_CLUB: FlinchChance.new,
	Constants.MOVES.FIRE_BLAST: BurnChance.new,
	Constants.MOVES.WATERFALL: FlinchChance.new,
	Constants.MOVES.CLAMP: TrapTarget.new,
	Constants.MOVES.SKULL_BASH: SkullBash.new,
	Constants.MOVES.SPIKE_CANNON: MultiStrikeMove.new,
	Constants.MOVES.CONSTRICT: LowerSpeedByOneChance.new,
	Constants.MOVES.AMNESIA: Amnesia.new,
	Constants.MOVES.KINESIS: LowerAccuracyByOne.new,
	Constants.MOVES.SOFT_BOILED: Heal50Percent.new,
	Constants.MOVES.HIGH_JUMP_KICK: CrashDamage.new,
	Constants.MOVES.GLARE: InflictParalysis.new,
	Constants.MOVES.DREAM_EATER: DreamEater.new,
	Constants.MOVES.POISON_GAS: InflictPoison.new,
	Constants.MOVES.BARRAGE: MultiStrikeMove.new,
	Constants.MOVES.LEECH_LIFE: Drain50Percent.new,
	Constants.MOVES.LOVELY_KISS: InflictSleep.new,
	Constants.MOVES.SKY_ATTACK: SkyAttack.new,
	Constants.MOVES.BUBBLE: LowerSpeedByOneChance.new,
	Constants.MOVES.DIZZY_PUNCH: ConfuseChance.new,
	Constants.MOVES.SPORE: InflictSleep.new,
	Constants.MOVES.FLASH: LowerAccuracyByOne.new,
	Constants.MOVES.PSYWAVE: Psywave.new,
	Constants.MOVES.SPLASH: Splash.new,
	Constants.MOVES.ACID_ARMOR: IncreaseDefenseByTwo.new,
	Constants.MOVES.FURY_SWIPES: MultiStrikeMove.new,
	Constants.MOVES.BONEMERANG: TwoHitMove.new,
	Constants.MOVES.REST: Rest.new,
	Constants.MOVES.ROCK_SLIDE: FlinchChance.new,
	Constants.MOVES.HYPER_FANG: FlinchChance.new,
	Constants.MOVES.SHARPEN: IncreaseAttackByOne.new,
	Constants.MOVES.TRI_ATTACK: TriAttack.new,
	Constants.MOVES.SUPER_FANG: SuperFang.new,
	Constants.MOVES.STRUGGLE: Recoil25Percent.new,
	Constants.MOVES.MIND_READER: LockOnTarget.new,
	Constants.MOVES.NIGHTMARE: Nightmare.new,
	Constants.MOVES.FLAME_WHEEL: BurnChance.new,
	Constants.MOVES.SNORE: Snore.new,
	Constants.MOVES.CURSE: Curse.new,
	Constants.MOVES.FLAIL: UserHPBasePower.new,
	Constants.MOVES.COTTON_SPORE: LowersSpeedByTwo.new,
	Constants.MOVES.REVERSAL: UserHPBasePower.new,
	Constants.MOVES.POWDER_SNOW: FreezeChance.new,
	Constants.MOVES.SCARY_FACE: LowersSpeedByTwo.new,
	Constants.MOVES.SWEET_KISS: InflictConfusion.new,
	Constants.MOVES.BELLY_DRUM: BellyDrum.new,
	Constants.MOVES.SLUDGE_BOMB: PoisonChance.new,
	Constants.MOVES.MUD_SLAP: LowerAccuracyByOneChance.new,
	Constants.MOVES.OCTAZOOKA: LowerAccuracyByOneChance.new,
	Constants.MOVES.ZAP_CANNON: ParalyzeChance.new,
	Constants.MOVES.PERISH_SONG: PerishSong.new,
	Constants.MOVES.ICY_WIND: LowerSpeedByOneChance.new,
	Constants.MOVES.BONE_RUSH: MultiStrikeMove.new,
	Constants.MOVES.LOCK_ON: LockOnTarget.new,
	Constants.MOVES.OUTRAGE: LockingMove.new,
	Constants.MOVES.GIGA_DRAIN: Drain50Percent.new,
	Constants.MOVES.CHARM: LowerAttackByTwo.new,
	Constants.MOVES.ROLLOUT: GraduallyStronger.new,
	Constants.MOVES.FALSE_SWIPE: FalseSwipe.new,
	Constants.MOVES.SWAGGER: Swagger.new,
	Constants.MOVES.MILK_DRINK: Heal50Percent.new,
	Constants.MOVES.SPARK: ParalyzeChance.new,
	Constants.MOVES.FURY_CUTTER: FuryCutter.new,
}

## Returns the handler for the move id provided, or the base move handler if it's not found.
static func get_move_handler(p_move: Move) -> MoveHandler:
	return moves.get(p_move.id, MoveHandler.new).call(p_move)

	
var move: Move


func _init(p_move: Move):
	move = p_move


## Returns the move's priority
func move_priority() -> int:
	return move.priority


## Returns which positions this move targets
func move_target() -> Constants.MOVE_TARGET:
	return move.target


## Called when the move is aborted for some reason (before_move event)
func on_aborted(_battle: Battle, _user: Battler, _target: Battler) -> void:
	return


## Called when the move is about to be used
## Returning false means the move doesn't go through (for example, on the charging turn of a two turn move)
func on_try_move(_battle: Battle, _user: Battler, _target: Battler) -> bool:
	return true


## Called when target is in a semi invulnerable state (Second part of Fly, Dig, etc.)
## Returning false means that invulnerability is bypassed and move execution continues
func on_invulnerability(_battle: Battle, _user: Battler, _target: Battler) -> bool:
	return true


## Returns the move's accuracy
func move_accuracy(_battle: Battle, _user: Battler, _target: Battler) -> int:
	return move.accuracy


## Called when the move misses
func on_miss(_battle: Battle, _user: Battler, _target: Battler) -> void:
	return


## Returns the damage to deal if the move has fixed damage
func fixed_damage(_battle: Battle, _user: Battler, _target: Battler) -> int:
	return 0


## Returns the move's base power
func base_power(_user: Battler, _target: Battler) -> int:
	return move.power


## Returns how many times this move hits
func number_of_hits(_battle: Battle) -> int:
	return 1


## Called right before dealing damage to the target
func on_damage(_battle: Battle, _user: Battler, _target: Battler, damage: int) -> int:
	return damage


## Called after the move is used, to activate its secondary effect if it has one
func on_secondary_effect(_battle: Battle, _user: Battler, _target: Battler) -> void:
	pass


## Called after the move is used, to apply recoil if the move has it
func on_recoil(_battle: Battle, _user: Battler, _damage: int) -> void:
	return


## Called when a move "saps" from target after using the move
func on_drain(_battle: Battle, _user: Battler, _damage: int) -> void:
	return


## What happens when the move is used. Mainly used for Status moves
func on_move_hit(_battle: Battle, _user: Battler, _target: Battler) -> void:
	print("Use move")
	

## Called before deducting PP, for locking moves
func on_move_locked(_battle: Battle, _user: Battler) -> bool:
	return false


class MultiStrikeMove extends MoveHandler:
	func number_of_hits(battle: Battle) -> int:
		var hit_chances: Array[int] = [
			2, 2, 2, 2, 2, 2, 2,
			3, 3, 3, 3, 3, 3, 3,
			4, 4, 4,
			5, 5, 5
		]
		var random: int = battle.random(len(hit_chances))
		return hit_chances[random]


class TwoTurnMove extends MoveHandler:
	func on_try_move(_battle: Battle, user: Battler, target: Battler) -> bool:
		if user.battler_flags.has("twoturnmove"):
			user.battler_flags.erase("twoturnmove")
			return true
		user.battler_flags["twoturnmove"] = [target.side, target.side.get_active_battler_position(target), move] # Set move to lock it in for next turn
		return false
	
	
	func on_aborted(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.battler_flags.erase("twoturnmove")
		print(move.name, " was interrupted")
		
	
	func on_move_locked(_battle: Battle, user: Battler) -> bool:
		return user.battler_flags.has("twoturnmove")


class BurnChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		if target.is_fainted():
			return
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print("Fire punch didn't burn the opponent")
			return
		target.set_status(Constants.STATUSES.BURN)


class FreezeChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		if target.is_fainted():
			return
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name + " didn't freeze the opponent")
			return
		print(move.name + " will freeze the opponent")
		target.set_status(Constants.STATUSES.FREEZE)


class ParalyzeChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		if target.is_fainted():
			return
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't paralyze the opponent")
			return
		print(move.name, " will paralyze the opponent")
		target.set_status(Constants.STATUSES.PARALYSIS)


class OHKOMove extends MoveHandler:
	func move_accuracy(_battle: Battle, user: Battler, target: Battler) -> int:
		if target.pokemon.level > user.pokemon.level:
			return -1 # Fails
		return user.pokemon.level - target.pokemon.level + 30


class RazorWind extends TwoTurnMove:
	func on_try_move(battle: Battle, user: Battler, target: Battler) -> bool:
		var result: bool = super(battle, user, target)
		if not result:
			battle.add_battle_event(BattleDialogueEvent.new("{0} whipped up a whirlwind!", [user.pokemon.name]))
		return result


class SwordsDance extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("attack", 2, target)


class Gust extends MoveHandler:
	func on_invulnerability(_battle: Battle, _user: Battler, target: Battler) -> bool:
		if target.battler_flags.has("twoturnmove"):
			if target.battler_flags.get("twoturnmove")[2].id == Constants.MOVES.FLY:
				return false
		return true


	func base_power(_user: Battler, target: Battler) -> int:
		if target.battler_flags.has("twoturnmove"):
			if target.battler_flags.get("twoturnmove")[2].id == Constants.MOVES.FLY:
				return move.power * 2
		return move.power


class ForceSwitch extends MoveHandler:
	func move_accuracy(_battle: Battle, _user: Battler, _target: Battler) -> int:
		return -1 # Bypasses accuracy checks

		
	func on_move_hit(battle: Battle, _user: Battler, target: Battler) -> void:
		var drag_in: Battler = target.side.get_random_switch()
		if drag_in == null:
			battle.add_battle_event(BattleDialogueEvent.new("But it failed!"))
			return
		var switch_action := SwitchAction.new(target, drag_in, battle)
		switch_action.execute()


class Fly extends TwoTurnMove:
	func on_try_move(battle: Battle, user: Battler, target: Battler) -> bool:
		var result: bool = super(battle, user, target)
		if not result:
			battle.add_battle_event(BattleDialogueEvent.new("{0} took flight!", [user.pokemon.name]))
		return result


class TrapTarget extends MoveHandler:
	func on_secondary_effect(battle: Battle, user: Battler, target: Battler) -> void:
		if not target.battler_flags.has("bound"):
			target.battler_flags["bound"] = [FlagHandler.get_flag_handler(Constants.FLAGS.BOUND, target), 4 + battle.random(2)]
			battle.add_battle_event(BattleDialogueEvent.new("{0} was squeezed by {1}!", [target.pokemon.name, user.pokemon.name]))


class FlinchChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't make the opponent flinch")
			return
		print(move.name, " will make the opponent flinch")
		if not target.battler_flags.has("flinch"):
			target.battler_flags["flinch"] = [FlagHandler.get_flag_handler(Constants.FLAGS.FLINCH, target)]


class Stomp extends FlinchChance:
	func move_accuracy(battle: Battle, user: Battler, target: Battler) -> int:
		if target.battler_flags.has("minimize"):
			return -1
		return super(battle, user, target)


	func base_power(_user: Battler, target: Battler) -> int:
		if target.battler_flags.has("minimize"):
			return move.power * 2
		return super(_user, target)


class TwoHitMove extends MoveHandler:
	func number_of_hits(_battle: Battle) -> int:
		return 2


class CrashDamage extends MoveHandler:
	func on_miss(battle: Battle, user: Battler, _target: Battler) -> void:
		battle.add_battle_event(BattleDialogueEvent.new("{0} kept going and crashed!", [user.pokemon.name]))
		user.damage(int(user.pokemon.stats.hp / 2))


class LowerAccuracyByOne extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("accuracy", -1, user)


class BodySlam extends ParalyzeChance:
	func move_accuracy(battle: Battle, user: Battler, target: Battler) -> int:
		if target.battler_flags.has("minimize"):
			return -1
		return super(battle, user, target)


	func base_power(_user: Battler, target: Battler) -> int:
		if target.battler_flags.has("minimize"):
			return move.power * 2
		return super(_user, target)


class Recoil25Percent extends MoveHandler:
	func on_recoil(battle: Battle, user: Battler, damage: int) -> void:
		battle.add_battle_event(BattleDialogueEvent.new("{0} took recoil damage!", [user.pokemon.name]))
		user.damage(int(damage / 4))


class LockingMove extends MoveHandler:
	func on_try_move(battle: Battle, user: Battler, target: Battler) -> bool:
		if not user.battler_flags.has("lockedmove"):
			user.battler_flags["lockedmove"] = [
				FlagHandler.get_flag_handler(Constants.FLAGS.LOCKED_MOVE, user),
				target,
				move,
				battle.random_range(3, 4)] # One more because it's reduced on the same turn it's added
		else:
			battle.add_battle_event(BattleDialogueEvent.new("{0} is locked into {1}!", [user.pokemon.name, move.name]))
		return true


	func on_move_locked(_battle: Battle, user: Battler) -> bool:
		return user.battler_flags.has("lockedmove")


class DoubleEdge extends MoveHandler:
	func on_recoil(battle: Battle, user: Battler, damage: int) -> void:
		battle.add_battle_event(BattleDialogueEvent.new("{0} took recoil damage!", [user.pokemon.name]))
		user.damage(int(damage / 3))


class LowerDefenseByOne extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("defense", -1, user)


class PoisonChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't poison the opponent")
			return
		print(move.name, " will poison the opponent")
		target.set_status(Constants.STATUSES.POISON)


class Twineedle extends PoisonChance:
	func number_of_hits(_battle: Battle) -> int:
		return 2


class Growl extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("attack", -1, user)


class InflictSleep extends MoveHandler:
	func on_move_hit(battle: Battle, _user: Battler, target: Battler) -> void:
		if move.flags.has(Constants.MOVE_FLAGS.POWDER):
			for type in target.pokemon.species.types:
				if type.id == Constants.TYPES.GRASS:	
					battle.add_battle_event(BattleDialogueEvent.new("{0} is immune to {1}!", [target.pokemon.name, move.name]))
					print(target.pokemon.name, " can't be put to sleep with ", move.name, " because it's a Grass type!")
					return
		target.set_status(Constants.STATUSES.SLEEP)


class InflictConfusion extends MoveHandler:
	func on_move_hit(battle: Battle, _user: Battler, target: Battler) -> void:
		if target.battler_flags.has("confusion"):
			battle.add_battle_event(BattleDialogueEvent.new("{0} is already confused!", [target.pokemon.name]))
			return
		target.battler_flags["confusion"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.CONFUSION, target),
			battle.random_range(2, 4),
		]
		print(move.name, " will confuse the opponent")


class SonicBoom extends MoveHandler:
	func fixed_damage(_battle: Battle, _user: Battler, _target: Battler) -> int:
		return 20


class Disable extends MoveHandler:
	func on_try_move(_battle: Battle, _user: Battler, target: Battler) -> bool:
		if target.last_move_used == Constants.MOVES.NONE or target.last_move_used == Constants.MOVES.STRUGGLE:
			print("No move to disable")
			return false
		if target.battler_flags.has("disable"):
			print("A move is already disabled")
			return false
		return true
		
	func on_move_hit(_battle: Battle, _user: Battler, target: Battler) -> void:
		target.battler_flags["disable"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.DISABLE, target),
			target.last_move_used,
			4, # Duration
		]
		print(move.name, " will disable the opponent's move")


class LowerSpecialDefenseByOneChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't lower the opponent's special defense")
			return
		target.boost_stat("special_defense", -1, user)


class Mist extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, _target: Battler) -> void:
		if user.side.side_flags.has("mist"):
			battle.add_battle_event(BattleDialogueEvent.new("Mist is already in place!"))
			return
		user.side.side_flags["mist"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.MIST, user),
			user,
			5 # Duration
		]
		print(move.name, " will protect the side!")


class ConfuseChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't confuse the opponent")
			return
		if target.battler_flags.has("confusion"):
			battle.add_battle_event(BattleDialogueEvent.new("{0} is already confused!", [target.pokemon.name]))
			return
		target.battler_flags["confusion"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.CONFUSION, target),
			battle.random_range(2, 4),
		]
		print(move.name, " will confuse the opponent")
			

class LowerSpeedByOneChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't lower the opponent's speed")
			return
		target.boost_stat("speed", -1, user)


class AuroraBeam extends MoveHandler:
	func on_secondary_effect(battle: Battle, user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't lower the opponent's attack")
			return
		target.boost_stat("attack", -1, user)


class RechargeMove extends MoveHandler:
	func on_secondary_effect(_battle: Battle, user: Battler, target: Battler) -> void:
		user.battler_flags["recharge"] = [FlagHandler.get_flag_handler(Constants.FLAGS.RECHARGE, user), target, move]


class LowKick extends MoveHandler:
	func base_power(_user: Battler, target: Battler) -> int:
		var weight: float = target.pokemon.species.weight
		print(target.pokemon.name, " weighs ", weight)
		if weight >= 200.0:
			return 120
		elif weight > 100.0:
			return 100
		elif weight > 50.0:
			return 80
		elif weight > 25.0:
			return 60
		elif weight > 10.0:
			return 40
		return 20


class UserLevelDamage extends MoveHandler:
	func fixed_damage(_battle: Battle, user: Battler, _target: Battler) -> int:
		return user.pokemon.level


class Drain50Percent extends MoveHandler:
	func on_drain(_battle: Battle, user: Battler, damage: int) -> void:
		user.heal(maxi(1, int(damage / 2)))


class LeechSeed extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler) -> void:
		if target.battler_flags.has("seeded"):
			battle.add_battle_event(BattleDialogueEvent.new("{0} is already seeded!", [target.pokemon.name]))
			return
		target.battler_flags["seeded"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.SEEDED, target),
			user,
			user.side.get_active_battler_position(user),
		]
		print(move.name, " will seed the opponent")


class Growth extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("attack", 1, target)
		user.boost_stat("special_attack", 1, target)


class InflictPoison extends MoveHandler:
	func on_move_hit(battle: Battle, _user: Battler, target: Battler) -> void:
		if move.flags.has(Constants.MOVE_FLAGS.POWDER):
			for type in target.pokemon.species.types:
				if type.id == Constants.TYPES.GRASS:	
					battle.add_battle_event(BattleDialogueEvent.new("{0} is immune to {1}!", [target.pokemon.name, move.name]))
					print(target.pokemon.name, " can't be poisoned with ", move.name, " because it's a Grass type!")
					return
		target.set_status(Constants.STATUSES.POISON)


class InflictParalysis extends MoveHandler:
	func on_move_hit(battle: Battle, _user: Battler, target: Battler) -> void:
		if move.flags.has(Constants.MOVE_FLAGS.POWDER):
			for type in target.pokemon.species.types:
				if type.id == Constants.TYPES.GRASS:	
					battle.add_battle_event(BattleDialogueEvent.new("{0} is immune to {1}!", [target.pokemon.name, move.name]))
					print(target.pokemon.name, " can't be paralyzed with ", move.name, " because it's a Grass type!")
					return
		target.set_status(Constants.STATUSES.PARALYSIS)


class LowersSpeedByTwo extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("speed", -2, user)


class DragonRage extends MoveHandler:
	func fixed_damage(_battle: Battle, _user: Battler, _target: Battler) -> int:
		return 40


class Thunder extends ParalyzeChance:
	func on_invulnerability(_battle: Battle, _user: Battler, target: Battler) -> bool:
		if target.battler_flags.has("twoturnmove"):
			if target.battler_flags.get("twoturnmove")[2].id == Constants.MOVES.FLY:
				return false
		return true


class Earthquake extends MoveHandler:
	func on_invulnerability(_battle: Battle, _user: Battler, target: Battler) -> bool:
		if target.battler_flags.has("twoturnmove"):
			if target.battler_flags.get("twoturnmove")[2].id == Constants.MOVES.DIG:
				return false
		return true

	## TODO: This should be modify damage, not base power
	func base_power(_user: Battler, target: Battler) -> int:
		if target.battler_flags.has("twoturnmove"):
			if target.battler_flags.get("twoturnmove")[2].id == Constants.MOVES.DIG:
				return move.power * 2
		return move.power


class Fissure extends OHKOMove:
	func on_invulnerability(_battle: Battle, _user: Battler, target: Battler) -> bool:
		if target.battler_flags.has("twoturnmove"):
			if target.battler_flags.get("twoturnmove")[2].id == Constants.MOVES.DIG:
				return false
		return true


class Toxic extends MoveHandler:
	func move_accuracy(_battle: Battle, user: Battler, _target: Battler) -> int:
		for type in user.pokemon.species.types:
			if type.id == Constants.TYPES.POISON:
				return -1
		return move.accuracy


	func on_invulnerability(_battle: Battle, user: Battler, _target: Battler) -> bool:
		for type in user.pokemon.species.types:
			if type.id == Constants.TYPES.POISON:
				return false
		return true


	func on_move_hit(_battle: Battle, _user: Battler, target: Battler) -> void:
		target.set_status(Constants.STATUSES.BAD_POISON)


class IncreaseAttackByOne extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("attack", 1, target)


class Agility extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("speed", 2, target)


class Rage extends MoveHandler:
	func on_secondary_effect(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.battler_flags["rage"] = [FlagHandler.get_flag_handler(Constants.FLAGS.RAGE, user)]


class Teleport extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, _target: Battler) -> void:
		if not user.can_switch_out():
			battle.add_battle_event(BattleDialogueEvent.new("But it failed!"))
			return
		battle.add_battle_event(RequestSwitchEvent.new(battle, user))


class Screech extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("defense", -2, user)


class DoubleTeam extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("evasion", 1, target)


class Heal50Percent extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.heal(ceil(user.pokemon.stats.hp / 2))


class IncreaseDefenseByOne extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("defense", 1, target)


class Minimize extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("evasion", 2, target)
		user.battler_flags["minimize"] = true


class DefenseCurl extends IncreaseDefenseByOne:
	func on_move_hit(battle: Battle, user: Battler, target: Battler) -> void:
		super(battle, user, target)
		user.battler_flags["defense_curl"] = true


class IncreaseDefenseByTwo extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("defense", 2, target)


class Screen extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, _target: Battler) -> void:
		var flag: String = "light_screen"
		var handler: Constants.FLAGS = Constants.FLAGS.LIGHT_SCREEN
		if move.id == Constants.MOVES.REFLECT:
			flag = "reflect"
			handler = Constants.FLAGS.REFLECT
		if user.side.side_flags.has(flag):
			battle.add_battle_event(BattleDialogueEvent.new("{0} is already in place!", [move.name]))
			return
		user.side.side_flags[flag] = [
			FlagHandler.get_flag_handler(handler, user),
			user,
			move.id,
			5 # Duration
		]
		print(move.name, " will protect the side!")


class Haze extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.reset_stat_stages()
		target.reset_stat_stages()


class FocusEnergy extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, _target: Battler) -> void:
		if user.battler_flags.has("focused"):
			battle.add_battle_event(BattleDialogueEvent.new("{0} is already focused!", [user.pokemon.name]))
			return
		user.battler_flags["focused"] = [FlagHandler.get_flag_handler(Constants.FLAGS.FOCUSED, user)]


class SkullBash extends TwoTurnMove:
	func on_try_move(battle: Battle, user: Battler, target: Battler) -> bool:
		var success: bool = super(battle, user, target)
		if not success:
			user.boost_stat("defense", 1, target) # If it's the turn the move is selected
		return success


class Amnesia extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		user.boost_stat("special_defense", 2, target)


class DreamEater extends Drain50Percent:
	func on_try_move(_battle: Battle, _user: Battler, target: Battler) -> bool:
		if target.has_status(Constants.STATUSES.SLEEP):
			return true
		print(target.pokemon.name, " wasn't asleep so ", move.name, " did nothing!")
		return false


class SkyAttack extends TwoTurnMove:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't make the opponent flinch")
			return
		print(move.name, " will make the opponent flinch")
		if not target.battler_flags.has("flinch"):
			target.battler_flags["flinch"] = [FlagHandler.get_flag_handler(Constants.FLAGS.FLINCH, target)]


class Psywave extends MoveHandler:
	func fixed_damage(battle: Battle, user: Battler, _target: Battler) -> int:
		var damage: float = (user.pokemon.level * (battle.random_range(0, 100) + 50) / 100)
		return maxi(1, int(damage))


class Splash extends MoveHandler:
	func on_move_hit(battle: Battle, _user: Battler, _target: Battler) -> void:
		battle.add_battle_event(BattleDialogueEvent.new("But nothing happened!"))


class Rest extends MoveHandler:
	func on_try_move(battle: Battle, user: Battler, _target: Battler) -> bool:
		if user.has_status(Constants.STATUSES.SLEEP):
			return false
		if user.pokemon.current_hp == user.pokemon.stats.hp:
			battle.add_battle_event(BattleDialogueEvent.new("{0}'s HP is full!", [user.pokemon.name]))
			return false
		return true
	
	func on_move_hit(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.set_status(Constants.STATUSES.SLEEP, true)
		if not user.battler_flags.has("sleep"):
			print(user.pokemon.name, " couldn't fall asleep while trying to Rest!")
			return
		user.battler_flags["sleep"] = 3 # Overwrite duration
		user.heal(user.pokemon.stats.hp)


class TriAttack extends MoveHandler:
	func on_secondary_effect(battle: Battle, _user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't paralyze/burn/freeze the opponent")
			return
		var status: Constants.STATUSES = [Constants.STATUSES.PARALYSIS, Constants.STATUSES.BURN, Constants.STATUSES.FREEZE].pick_random()
		target.set_status(status)


class SuperFang extends MoveHandler:
	func fixed_damage(_battle: Battle, _user: Battler, target: Battler) -> int:
		return maxi(1, int(target.pokemon.current_hp / 2))


class LockOnTarget extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler) -> void:
		if user.battler_flags.has("locked_on"):
			return
		battle.add_battle_event(BattleDialogueEvent.new("{0} took aim at {1}!", [user.pokemon.name, target.pokemon.name]))
		# True means it was used this turn/it's active, so it doesn't get erased on the same turn.
		user.battler_flags["locked_on"] = [FlagHandler.get_flag_handler(Constants.FLAGS.LOCKED_ON, user), target, true]
		

class Nightmare extends MoveHandler:
	func on_move_hit(battle: Battle, _user: Battler, target: Battler) -> void:
		if target.battler_flags.has("nightmare"):
			return
		if not target.has_status(Constants.STATUSES.SLEEP):
			return
		battle.add_battle_event(BattleDialogueEvent.new("{0} began having a nightmare!", [target.pokemon.name]))
		target.battler_flags["nightmare"] = [FlagHandler.get_flag_handler(Constants.FLAGS.NIGHTMARE, target)]


class Snore extends FlinchChance:
	func on_try_move(_battle: Battle, user: Battler, _target: Battler) -> bool:
		return user.has_status(Constants.STATUSES.SLEEP)


class Curse extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler) -> void:
		for type in user.pokemon.species.types:
			if type.id == Constants.TYPES.GHOST:
				if target.battler_flags.has("curse"):
					return
				user.damage(floor(user.pokemon.stats.hp / 2.0))
				battle.add_battle_event(BattleDialogueEvent.new("{0} cut its own HP and laid a curse on {1}!", [user.pokemon.name, target.pokemon.name]))
				target.battler_flags["curse"] = [FlagHandler.get_flag_handler(Constants.FLAGS.CURSE, target)]
				return
		# May need to have all these boosted at once
		user.boost_stat("speed", -1)
		user.boost_stat("attack", 1)
		user.boost_stat("defense", 1)
		

class UserHPBasePower extends MoveHandler:
	func base_power(user: Battler, _target: Battler) -> int:
		var ratio: int = maxi(floorf(float(user.pokemon.current_hp * 48) / float(user.pokemon.stats.hp)), 1)
		if ratio < 2:
			return 200
		elif ratio < 5:
			return 150
		elif ratio < 10:
			return 100
		elif ratio < 17:
			return 80
		elif ratio < 33:
			return 40
		return 20


class BellyDrum extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, _target: Battler) -> void:
		if user.pokemon.current_hp <= user.pokemon.stats.hp / 2 or user.stat_stages.attack >= 6:
			return
		user.damage(user.pokemon.stats.hp / 2)
		user.boost_stat("attack", 12)


class LowerAccuracyByOneChance extends MoveHandler:
	func on_secondary_effect(battle: Battle, user: Battler, target: Battler) -> void:
		var random_chance: int = battle.random_range(1, 100)
		if random_chance > move.effect_chance:
			print(move.name, " didn't lower the opponent's accuracy")
			return
		target.boost_stat("accuracy", -1, user)


class PerishSong extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler) -> void:
		if not user.battler_flags.has("perish_song"):
			user.battler_flags["perish_song"] = [FlagHandler.get_flag_handler(Constants.FLAGS.PERISH_SONG, target), 4]
			battle.add_battle_event(BattleDialogueEvent.new("All Pokémon hearing the song will faint in three turns!"))
		if not target.battler_flags.has("perish_song"):
			target.battler_flags["perish_song"] = [FlagHandler.get_flag_handler(Constants.FLAGS.PERISH_SONG, target), 4]


class LowerAttackByTwo extends MoveHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("attack", -2, user)


class GraduallyStronger extends MoveHandler:
	func base_power(user: Battler, _target: Battler) -> int:
		var base_power: int = move.power
		var move_arr: Array = user.battler_flags.get("gradually_stronger", [])
		if len(move_arr) > 0:
			base_power *= pow(2, move_arr[2])
		if user.battler_flags.has("defense_curl"):
			base_power *= 2
		return base_power

	# Might need to move to a different function
	func on_move_hit(_battle: Battle, user: Battler, target: Battler) -> void:
		var move_arr: Array = user.battler_flags.get("gradually_stronger", [])
		var count: int = 1
		if len(move_arr) > 0:
			count = move_arr[2] + 1
		if count >= 5:
			user.battler_flags.erase("gradually_stronger")
			return
		user.battler_flags["gradually_stronger"] = [target, move, count]


	func on_miss(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.battler_flags.erase("gradually_stronger")


	func on_aborted(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.battler_flags.erase("gradually_stronger")


class FalseSwipe extends MoveHandler:
	func on_damage(_battle: Battle, _user: Battler, target: Battler, damage: int) -> int:
		if damage >= target.pokemon.current_hp:
			return target.pokemon.current_hp - 1
		return damage


class Swagger extends MoveHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler) -> void:
		target.boost_stat("attack", 2, user)
		target.battler_flags["confusion"] = [
			FlagHandler.get_flag_handler(Constants.FLAGS.CONFUSION, target),
			battle.random_range(2, 4),
		]


class FuryCutter extends MoveHandler:
	func base_power(user: Battler, _target: Battler) -> int:
		var base_power: int = move.power
		if user.last_move_used != move.id:
			user.battler_flags.erase("fury_cutter")
		var hit: int = user.battler_flags.get("fury_cutter", 0) + 1
		user.battler_flags["fury_cutter"] = hit
		return clampi(base_power * pow(2, hit-1), 1, 160)

	func on_miss(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.battler_flags.erase("fury_cutter")


	func on_aborted(_battle: Battle, user: Battler, _target: Battler) -> void:
		user.battler_flags.erase("fury_cutter")
