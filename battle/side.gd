class_name Side
extends Resource
## Holds information about a side (player or opponent) in battle,
## including active battlers, effects affecting this side, etc.

var battlers: Array[Battler] ## All battlers on this side
var active: Array[Battler] ## All active battlers on this side
var side_flags: Dictionary ## Flags that affect side
var battlers_actioned: Array[Battler] ## The active battlers that have chosen an action
var current_battler_index: int = 0 ## The index of the current active battler choosing an action


func _init(team: Array[Battler], size: int = 1):
	for battler in team:
		battler.side = self
	battlers = team
	for i in range(size):
		active.push_back(battlers[i])


## [Public] Gets all allies for the specified battler
func get_allies(battler: Battler) -> Array[Battler]:
	var allies: Array[Battler] = []
	for ally in battlers:
		if ally == battler: continue
		allies.append(ally)
	return allies


## [Public] Gets the active Pokemon (not battlers) in this side
func get_active_pokemon() -> Array[Pokemon]:
	var active_pokemon: Array[Pokemon] = []
	for a in active:
		active_pokemon.push_back(a.pokemon)
	return active_pokemon


## [Public] Switches an active battler with another battler.
func switch_active_battler(switch_out: Battler, switch_in: Battler) -> void:
	var out_position: int = 0
	var in_position: int = 0
	for i in battlers.size():
		if battlers[i] == switch_out:
			out_position = i
		elif battlers[i] == switch_in:
			in_position = i
	battlers[out_position] = switch_in
	battlers[in_position] = switch_out
	for i in active.size():
		if switch_out == active[i]:
			active[i] = switch_in
			break


## [Public] Gets the specified battler's position if it's active, without considering if it's fainted or not.
## If the battler is not active, it returns -1
func get_active_battler_position(battler: Battler) -> int:
	for i in active.size():
		if battler == active[i]:
			return i
	return -1
	

## [Public] Returns the battler's position (index) in this side.
## If battler is not found, it returns -1.
func get_battler_position(battler: Battler) -> int:
	for i in battlers.size():
		if battler == battlers[i]:
			return i
	return -1
	

## [Public] Gets a random battler that it's not active or fainted to switch in
## Returns null if there are no suitable battlers
func get_random_switch() -> Battler:
	var switchable: Array[Battler] = []
	for battler in battlers:
		if battler in active or battler.is_fainted():
			continue
		switchable.push_back(battler)
	if len(switchable) <= 0:
		return null
	return switchable.pick_random()


## [Public] Checks if a battler can switch in or not
func can_switch_in(switch_in: Battler, display_messages: bool = true) -> bool:
	var message := ""
	if switch_in not in battlers:
		message = "This Pokemon doesn't belong to you"
	elif switch_in in active:
		message = "Pokemon is already in battle"
	elif switch_in.is_fainted():
		message = "Pokemon is fainted"
	else:
		for battle_switch in switch_in.battle.battle_actions:
			if battle_switch is SwitchAction and battle_switch.switch_in == switch_in:
				message = "Will already be switched in"
				break
	if message and display_messages:
		SignalBus.display_message.emit(message)
		return false
	return message.is_empty()
