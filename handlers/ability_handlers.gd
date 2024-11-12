class_name AbilityHandler
## Base ability handler
## Other abilities override the methods they need
## Methods are roughly ordered the way they happen in battle

# TODO: Better way to check for ally side when an ability is activated instead of this battle.sides[0] == target.side

static var abilities: Dictionary = {
	Constants.ABILITIES.STENCH: Stench.new,
	Constants.ABILITIES.SPEED_BOOST: SpeedBoost.new,
	Constants.ABILITIES.BATTLE_ARMOR: PreventCriticalHits.new,
	Constants.ABILITIES.STURDY: Sturdy.new,
	Constants.ABILITIES.DAMP: Damp.new,
	Constants.ABILITIES.LIMBER: Limber.new,
	Constants.ABILITIES.STATIC: Static.new,
	Constants.ABILITIES.VOLT_ABSORB: VoltAbsorb.new,
	Constants.ABILITIES.WATER_ABSORB: WaterAbsorb.new,
	Constants.ABILITIES.COMPOUND_EYES: CompoundEyes.new,
	Constants.ABILITIES.INSOMNIA: PreventSleep.new,
	Constants.ABILITIES.IMMUNITY: Immunity.new,
	Constants.ABILITIES.FLASH_FIRE: FlashFire.new,
	Constants.ABILITIES.ROUGH_SKIN: RoughSkin.new,
	Constants.ABILITIES.WONDER_GUARD: WonderGuard.new,
	Constants.ABILITIES.LEVITATE: Levitate.new,
	Constants.ABILITIES.EFFECT_SPORE: EffectSpore.new,
	Constants.ABILITIES.CLEAR_BODY: PreventStatLowering.new,
	Constants.ABILITIES.LIGHTNING_ROD: LightningRod.new,
	Constants.ABILITIES.SERENE_GRACE: SereneGrace.new,
	Constants.ABILITIES.HUGE_POWER: HugePower.new,
	Constants.ABILITIES.POISON_POINT: PoisonPoint.new,
	Constants.ABILITIES.MAGMA_ARMOR: MagmaArmor.new,
	Constants.ABILITIES.WATER_VEIL: WaterVeil.new,
	Constants.ABILITIES.SOUNDPROOF: Soundproof.new,
	Constants.ABILITIES.THICK_FAT: ThickFat.new,
	Constants.ABILITIES.FLAME_BODY: FlameBody.new,
	Constants.ABILITIES.KEEN_EYE: KeenEye.new,
	Constants.ABILITIES.HYPER_CUTTER: HyperCutter.new,
	Constants.ABILITIES.TRUANT: Truant.new,
	Constants.ABILITIES.HUSTLE: Hustle.new,
	Constants.ABILITIES.SHED_SKIN: ShedSkin.new,
	Constants.ABILITIES.GUTS: Guts.new,
	Constants.ABILITIES.MARVEL_SCALE: MarvelScale.new,
	Constants.ABILITIES.OVERGROW: Overgrow.new,
	Constants.ABILITIES.BLAZE: Blaze.new,
	Constants.ABILITIES.TORRENT: Torrent.new,
	Constants.ABILITIES.SWARM: Swarm.new,
	Constants.ABILITIES.VITAL_SPIRIT: PreventSleep.new,
	Constants.ABILITIES.WHITE_SMOKE: PreventStatLowering.new,
	Constants.ABILITIES.PURE_POWER: PurePower.new,
	Constants.ABILITIES.SHELL_ARMOR: PreventCriticalHits.new,
}

## Returns the handler for the ability id provided, or the base ability handler if it's not found.
static func get_ability_handler(p_ability: Ability) -> AbilityHandler:
	return abilities.get(p_ability.id, AbilityHandler.new).call(p_ability)


var ability: Ability


func _init(p_ability: Ability):
	ability = p_ability


## Checks if battler has the ability
func has_ability(battler: Battler) -> bool:
	return battler.pokemon.ability.id == ability.id


## Subpriority modifier when calculating priority
func on_priority_bracket_change(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> float:
	return 0.0


## Called before a move is used
## Returning false means the move shouldn't be used
func on_before_move(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> bool:
	return true


## Called right after on_before_move
## Modifies the move in any way the ability has to
func on_modify_move(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> void:
	return


## Called when a move is trying to be used and after it's been modified
## Returning false means the move fails
func on_try_move(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> bool:
	return true


## Called when calculating accuracy for a move
## Returns the new base accuracy
func on_modify_accuracy(_battle: Battle, _user: Battler, _target: Battler, _move: Move, accuracy: int) -> int:
	return accuracy


## Called when a move is about to hit the target
## Returning false means the move doesn't hit the target
func on_try_hit(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> bool:
	return true


## Called when a critical hit is going to happen
## Returning false means the critical hit shouldn't happen
func on_critical_hit(_battle: Battle, _user: Battler, _target: Battler) -> bool:
	return true


## Called when calculating the attack stat to apply to the damage formula
## attack_type if physical attack or special attack is being used
## Returns the modifier to apply to the stat
func on_modify_attack(_battle: Battle, _user: Battler, _target: Battler, _attack_type: String, _move: Move) -> float:
	return 1.0


## Called when calculating the defense stat to apply to the damage formula
## defense_type if physical defense or special defense is being used
## Returns the modifier to apply to the stat
func on_modify_defense(_battle: Battle, _user: Battler, _target: Battler, _defense_type: String, _move: Move) -> float:
	return 1.0


## Called before dealing damage to the target
## It returns the new damage to be dealt
func on_before_damage(_battle: Battle, _user: Battler, _target: Battler, _move: Move, damage: int) -> int:
	return damage


## Called when a damaging hit connects with the target
func on_move_hit(_battle: Battle, _user: Battler, _target: Battler, _move: Move) -> void:
	return


## Called after a secondary effect of a move
func on_secondary_effect(_battle: Battle, _user: Battler, _target: Battler) -> void:
	return


## Called at the end of a turn
func on_residual(_battle: Battle, _battler: Battler) -> void:
	return


## Called when a battler is about to change a stat stage
## Returning false means the change should not happen
func on_try_boost(_battle: Battle, _user: Battler, _target: Battler, _boost: Stats) -> bool:
	return true


## Called when trying to set a status on battler
## Returning false means the status shouldn't be set
func on_try_set_status(_battle: Battle, _battler: Battler, _status: Constants.STATUSES) -> bool:
	return true


class Stench extends AbilityHandler:
	func on_secondary_effect(_battle: Battle, _user: Battler, _target: Battler) -> void:
		return
		## TODO: Commenting for now. Need to change how moves secondary effects work/are known
		#if not has_ability(user, Constants.ABILITIES.STENCH): return
		#if target.is_fainted() or target.battler_flags.has("flinch"):
			#return
			#
		#var random_chance: int = battle.random_range(1, 100)
		#if random_chance > 10:
			#print("Stench didn't make the opponent flinch ", target.pokemon.name)
			#return
		#battle.add_battle_event(AbilityEvent.new(battle.sides[0] == user.side, user, ability))
		#if not target.battler_flags.has("flinch"):
			#target.battler_flags["flinch"] = [FlagHandler.get_flag_handler(Constants.FLAGS.FLINCH, target)]


class SpeedBoost extends AbilityHandler:
	func on_residual(battle: Battle, battler: Battler) -> void:
		if battler.switched_in_this_turn:
			return
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
		battler.boost_stat("speed", 1)


class PreventCriticalHits extends AbilityHandler:
	func on_critical_hit(battle: Battle, _user: Battler, target: Battler) -> bool:
		if not has_ability(target):
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
		return false


class Sturdy extends AbilityHandler:
	func on_try_hit(battle: Battle, _user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if move.is_ohko():
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
			return false
		return true


	func on_before_damage(_battle: Battle, _user: Battler, target: Battler, _move: Move, damage: int) -> int:
		if not has_ability(target):
			return damage
		if target.pokemon.stats.hp == target.pokemon.current_hp and damage >= target.pokemon.stats.hp:
			return target.pokemon.stats.hp - 1
		return damage


class Damp extends AbilityHandler:
	## TODO: Interaction with Aftermath
	func on_try_move(battle: Battle, user: Battler, target: Battler, move: Move) -> bool:
		if move.flags.has(Constants.MOVE_FLAGS.EXPLOSION):
			var battler := user
			if user.pokemon.ability.id != Constants.ABILITIES.DAMP:
				battler = target 
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
			return false
		return true


class Limber extends AbilityHandler:
	## TODO: Cure paralysis on gaining the ability
	func on_try_set_status(battle: Battle, battler: Battler, status: Constants.STATUSES) -> bool:
		if status != Constants.STATUSES.PARALYSIS:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
		return false


class Static extends AbilityHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler, move: Move) -> void:
		if not has_ability(target):
			return
		if not move.flags.has(Constants.MOVE_FLAGS.CONTACT):
			return
		if user.pokemon.status.id == Constants.STATUSES.PARALYSIS:
			return
		var random_chance: int = battle.random(100)
		var ignore_immunity: bool = false
		if random_chance < 30:
			for type in user.pokemon.species.types:
				if type.id == Constants.TYPES.ELECTRIC:
					ignore_immunity = false
					break
				elif type.id == Constants.TYPES.GROUND:
					ignore_immunity = true
			user.set_status(Constants.STATUSES.PARALYSIS, false, ignore_immunity)
		return


class VoltAbsorb extends AbilityHandler:
	func on_try_hit(battle: Battle, _user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if move.type == Constants.TYPES.ELECTRIC:
			target.heal(target.pokemon.stats.hp / 4)
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
			return false
		return true


class WaterAbsorb extends AbilityHandler:
	func on_try_hit(battle: Battle, _user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if move.type == Constants.TYPES.WATER:
			target.heal(target.pokemon.stats.hp / 4)
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
			return false
		return true


class CompoundEyes extends AbilityHandler:
	func on_modify_accuracy(_battle: Battle, user: Battler, _target: Battler, move: Move, accuracy: int) -> int:
		if not has_ability(user):
			return accuracy
		if move.is_ohko():
			return accuracy
		return int(accuracy * 1.3)


class PreventSleep extends AbilityHandler:
	func on_try_set_status(battle: Battle, battler: Battler, status: Constants.STATUSES) -> bool:
		if status != Constants.STATUSES.SLEEP:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
		return false


class Immunity extends AbilityHandler:
	func on_try_set_status(battle: Battle, battler: Battler, status: Constants.STATUSES) -> bool:
		if status != Constants.STATUSES.POISON or status != Constants.STATUSES.BAD_POISON:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
		return false


class FlashFire extends AbilityHandler:
	func on_try_hit(battle: Battle, _user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if move.type != Constants.TYPES.FIRE:
			return true
		if not target.battler_flags.has("flash_fire"):
			target.battler_flags["flash_fire"] = true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
		return false
	
	
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, _attack_type: String, move: Move) -> float:
		if user.battler_flags.has("flash_fire") and move.type == Constants.TYPES.FIRE:
			return 1.5
		return 1.0


class RoughSkin extends AbilityHandler:
	func on_move_hit(_battle: Battle, user: Battler, target: Battler, move: Move) -> void:
		if not has_ability(target):
			return
		if not move.flags.has(Constants.MOVE_FLAGS.CONTACT):
			return
		user.damage(user.pokemon.stats.hp / 8)
		return


class WonderGuard extends AbilityHandler:
	func on_try_hit(battle: Battle, _user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if not move.is_damaging() or move.type == Constants.TYPES.NONE: # Struggle
			return true
		var type_mod := 1.0
		for target_type in target.pokemon.species.types:
			if target_type.immunities.has(move.type):
				return false
			if target_type.weaknesses.has(move.type):
				type_mod *= 2.0
			elif target_type.resistances.has(move.type):
				type_mod *= 0.5
		if type_mod > 1.0:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
		return false


class Levitate extends AbilityHandler:
	func on_try_hit(battle: Battle, _user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if move.category == Constants.MOVE_CATEGORY.STATUS or move.type != Constants.TYPES.GROUND or move.id == Constants.MOVES.THOUSAND_ARROWS:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
		return false


class EffectSpore extends AbilityHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler, move: Move) -> void:
		if not has_ability(target):
			return
		if not move.flags.has(Constants.MOVE_FLAGS.CONTACT) or user.pokemon.ability.id == Constants.ABILITIES.OVERCOAT:
			return
		for type in user.pokemon.species.types:
			if type.id == Constants.TYPES.GRASS:
				return
		var random_chance: int = battle.random(100)
		if random_chance < 11:
			user.set_status(Constants.STATUSES.SLEEP)
		elif random_chance < 21:
			user.set_status(Constants.STATUSES.PARALYSIS)
		elif random_chance < 30:
			user.set_status(Constants.STATUSES.POISON)
		return


class PreventStatLowering extends AbilityHandler:
	func on_try_boost(battle: Battle, user: Battler, target: Battler, boost: Stats) -> bool:
		if not has_ability(target):
			return true
		if target == user:
			return true
		if boost.attack < 0 or boost.special_attack < 0 or boost.defense < 0 or boost.special_defense < 0 or boost.speed < 0 or boost.accuracy < 0 or boost.evasion < 0:
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
			return false
		return true


class LightningRod extends AbilityHandler:
	func on_try_hit(battle: Battle, user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if target == user or move.type != Constants.TYPES.ELECTRIC:
			return true
		target.boost_stat("special_attack", 1)
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
		return false


class SereneGrace extends AbilityHandler:
	func on_modify_move(_battle: Battle, _user: Battler, _target: Battler, move: Move) -> void:
		if move.is_damaging():
			move.effect_chance *= 2


class HugePower extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, attack_type: String, _move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if attack_type == "attack":
			return 2.0
		return 1.0


class PoisonPoint extends AbilityHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler, move: Move) -> void:
		if not has_ability(target):
			return
		if not move.flags.has(Constants.MOVE_FLAGS.CONTACT):
			return
		var random_chance: int = battle.random(100)
		if random_chance < 30:
			user.set_status(Constants.STATUSES.POISON)
		return


class MagmaArmor extends AbilityHandler:
	func on_try_set_status(battle: Battle, battler: Battler, status: Constants.STATUSES) -> bool:
		if status != Constants.STATUSES.FREEZE:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
		return false


class WaterVeil extends AbilityHandler:
	func on_try_set_status(battle: Battle, battler: Battler, status: Constants.STATUSES) -> bool:
		if status != Constants.STATUSES.BURN:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
		return false


class Soundproof extends AbilityHandler:
	func on_try_hit(battle: Battle, user: Battler, target: Battler, move: Move) -> bool:
		if not has_ability(target):
			return true
		if not move.flags.has(Constants.MOVE_FLAGS.SOUND) or target == user:
			return true
		battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
		return false


class ThickFat extends AbilityHandler:
	func on_modify_attack(_battle: Battle, _user: Battler, target: Battler, _attack_type: String, move: Move) -> float:
		if not has_ability(target):
			return 1.0
		if not [Constants.TYPES.ICE, Constants.TYPES.FIRE].has(move.type):
			return 1.0
		return 0.5


class FlameBody extends AbilityHandler:
	func on_move_hit(battle: Battle, user: Battler, target: Battler, move: Move) -> void:
		if not has_ability(target):
			return
		if not move.flags.has(Constants.MOVE_FLAGS.CONTACT):
			return
		var random_chance: int = battle.random(100)
		if random_chance < 30:
			user.set_status(Constants.STATUSES.BURN)
		return


class KeenEye extends AbilityHandler:
	func on_try_boost(battle: Battle, user: Battler, target: Battler, boost: Stats) -> bool:
		if not has_ability(target):
			return true
		if target == user:
			return true
		if boost.accuracy < 0:
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
			return false
		return true
	
	## TODO: Ignore target's evasion


class HyperCutter extends AbilityHandler:
	func on_try_boost(battle: Battle, user: Battler, target: Battler, boost: Stats) -> bool:
		if not has_ability(target):
			return true
		if target == user:
			return true
		if boost.attack < 0:
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == target.side, target, ability))
			return false
		return true


class Truant extends AbilityHandler:
	func on_before_move(battle: Battle, user: Battler, _target: Battler, _move: Move) -> bool:
		if not has_ability(user):
			return true
		if user.battler_flags.has("truant"):
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == user.side, user, ability))
			battle.add_battle_event(BattleDialogueEvent.new("{0} is loafing around!", [user.pokemon.name]))
			user.battler_flags.erase("truant")
			user.battler_flags.erase("recharge") # In case recharge handler doesn't run
			return false
		user.battler_flags["truant"] = true
		return true
		
	## TODO: If an ally faints due to end-of-turn damage (Burn, Poison, etc.), the pokemon sent in with Truant will loaf around on first turn.


class Hustle extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, attack_type: String, _move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if attack_type != "attack":
			return 1.0
		return 1.5

	func on_modify_accuracy(_battle: Battle, user: Battler, _target: Battler, move: Move, accuracy: int) -> int:
		if not has_ability(user):
			return accuracy
		if not move.is_physical():
			return accuracy
		return int(accuracy * 0.8) # Decreases for about 20% (3277/4096)


class ShedSkin extends AbilityHandler:
	func on_residual(battle: Battle, battler: Battler):
		if battler.is_fainted() or battler.pokemon.status.id == Constants.STATUSES.NONE:
			return
		var random_chance: int = battle.random(100)
		if random_chance < 33:
			battle.add_battle_event(AbilityEvent.new(battle.sides[0] == battler.side, battler, ability))
			battler.cure_status()


class Guts extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, attack_type: String, _move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if user.pokemon.status.id != Constants.STATUSES.NONE and attack_type == "attack":
			return 1.5
		return 1.0


class MarvelScale extends AbilityHandler:
	func on_modify_defense(_battle: Battle, _user: Battler, target: Battler, defense_type: String, _move: Move) -> float:
		if not has_ability(target):
			return 1.0
		if target.pokemon.status.id != Constants.STATUSES.NONE and defense_type == "defense":
			return 1.5
		return 1.0


class Overgrow extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, _attack_type: String, move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if move.type == Constants.TYPES.GRASS and user.pokemon.current_hp <= int(user.pokemon.stats.hp / 3):
			return 1.5
		return 1.0


class Blaze extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, _attack_type: String, move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if move.type == Constants.TYPES.FIRE and user.pokemon.current_hp <= int(user.pokemon.stats.hp / 3):
			return 1.5
		return 1.0


class Torrent extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, _attack_type: String, move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if move.type == Constants.TYPES.WATER and user.pokemon.current_hp <= int(user.pokemon.stats.hp / 3):
			return 1.5
		return 1.0


class Swarm extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, _attack_type: String, move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if move.type == Constants.TYPES.BUG and user.pokemon.current_hp <= int(user.pokemon.stats.hp / 3):
			return 1.5
		return 1.0


class PurePower extends AbilityHandler:
	func on_modify_attack(_battle: Battle, user: Battler, _target: Battler, attack_type: String, _move: Move) -> float:
		if not has_ability(user):
			return 1.0
		if attack_type != "attack":
			return 1.0
		return 2.0
