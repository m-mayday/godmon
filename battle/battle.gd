class_name Battle
extends Resource
## Driver for all battle related actions.
## It executes battle actions and runs through battle events.
## Battle actions are actions that a battler performs: using move, using item, etc.
## Battle events are events that can be used for pretty much anything: changing the battle state, displaying a message, playing an animation, etc.

## Emitted after all actions are queued and before the first action
signal turn_started()

## Emitted after all actions are executed
signal turn_ended(side_a_team, side_b_team)

## [Internal] Emitted when the battle state changes
## See STATE enum for possible values
signal state_changed(state: STATE)

## Emitted when a battler has chosen an action
signal action_chosen

## Possible state for battle
enum STATE {
	IDLE, ## IDLE - Initial value.
	COMMAND_PHASE, ## COMMAND_PHASE - Action queueing.
	ATTACKING_PHASE, ## ATTACKING_PHASE - Turn playing.
	PROCESSING_EVENTS, ## PROCESSING_EVENTS - Run through events (Text, Changes in battlers, etc.)
	END_TURN_PHASE, ## END_TURN_PHASE - Turn ended.
}

var player_team: Array[Battler] ## Player team
var opponent_team: Array[Battler] ## Opponent team
var prng: RandomNumberGenerator ## Seeder for the battle
var battle_actions: Array[BaseAction] ## Queued actions
var faint_queue: Array[Battler] ## Battlers that fainted this turn
var battle_events: Array[BaseEvent] ## Events to run through after an action is completed
var sides: Array[Side] ## Array of sides in battle. There are 2 sides: Player and Opponent.
var state: STATE = STATE.IDLE ## Current battle state
var battle_size: Constants.BATTLE_SIZE ## The type of battle, indicating the amount of active battlers per side


func _init(p_player_team: Array[Pokemon], p_opponent_team: Array[Pokemon], size: Constants.BATTLE_SIZE = Constants.BATTLE_SIZE.NORMAL) -> void:
	state_changed.connect(_on_state_changed)
	# Create battlers for each side
	for pokemon in p_player_team:
		player_team.push_back(Battler.new(pokemon, self))
	for pokemon in p_opponent_team:
		opponent_team.push_back(Battler.new(pokemon, self))
	var side_size: int
	battle_size = size
	match size:
		Constants.BATTLE_SIZE.DOUBLE:
			side_size = 2
		Constants.BATTLE_SIZE.TRIPLE:
			side_size = 3
		_:
			side_size = 1
	sides.push_back(Side.new(player_team, side_size))
	sides.push_back(Side.new(opponent_team, side_size))
	prng = RandomNumberGenerator.new() # Initialize RNG
	prng.randomize() # Generate seed


## [Public] Called when battle should start.
## It manages entry messages and sending out of battlers.
func battle_start() -> void:
	await run_battle_event(BattleStartEvent.new(sides[0], sides[1]))
	_change_state(STATE.COMMAND_PHASE)


## [Public] Adds a MoveAction to battle_actions and the user its side battlers_actioned
func queue_move(move: Move, user: Battler, target: Battler = null) -> void:
	battle_actions.push_back(MoveAction.new(move, user, target, self))
	user.side.battlers_actioned.push_back(user)
	user.side.current_battler_index += 1
	action_chosen.emit()


## [Public] Adds a SwitchAction to battle_actions and the switch_out battler to its side battlers_actioned
func queue_switch(switch_out: Battler, switch_in: Battler, is_instant_switch: bool = false) -> void:
	battle_actions.push_back(SwitchAction.new(switch_out, switch_in, self))
	if is_instant_switch:
		var remaining_events: Array[BaseEvent] = battle_events.duplicate()
		battle_events.clear()
		var action: BaseAction = battle_actions.pop_back()
		action.execute()
		battle_events.append_array(remaining_events)
		_battle_events_processing_phase()
		return
	switch_in.side.battlers_actioned.push_back(switch_out)
	switch_in.side.current_battler_index += 1
	action_chosen.emit()


## [Public] Rmoves the last action on the side and from battle_actions
func unqueue_action(side: Side) -> void:
	if state != STATE.COMMAND_PHASE or side == null:
		return
	if len(side.battlers_actioned) > 0:
		var unqueued_battler: Battler = side.battlers_actioned.pop_back()
		var actions_queue_size: int = battle_actions.size()
		for i in actions_queue_size:
			if battle_actions[i] is MoveAction:
				if battle_actions[i].user.id == unqueued_battler.id:
					battle_actions.remove_at(i)
					break
			elif battle_actions[i] is SwitchAction:
				if battle_actions[i].switch_out.id == unqueued_battler.id:
					battle_actions.remove_at(i)
					break
		side.current_battler_index -= 1
		action_chosen.emit() # A bit of a hack to avoid an infinite loop on command_phase


## [Public] Runs an action event for all handlers found for it on the target and user
## Returns an array with the results returned by the handlers
func run_action_event(event: String, target: Battler, user: Battler, args: Array, stop_first_false: bool = false) -> Array:
	var handlers_target: Array = _find_action_event_handlers(event, target)
	var handlers_user: Array = _find_action_event_handlers(event, user)
	var result: Array = []
	for handler in handlers_target:
		var call_result = handler.callv(args)
		result.push_back(call_result)
		if stop_first_false and call_result is bool and call_result == false:
			return result
	for handler in handlers_user:
		var call_result = handler.callv(args)
		result.push_back(call_result)
		if stop_first_false and call_result is bool and call_result == false:
			return result
	return result


## [Private] Finds all action event handlers for the specified battler and returns them in an array
## Event handlers can come from the battler's status, ability, item, flags, etc.
func _find_action_event_handlers(event: String, battler: Battler) -> Array:
	var handlers: Array = []
	if battler == null:
		return handlers
	var handler_types = ["status", "ability", "item"]
	for handler_type in handler_types:
		var type: Variant = battler.pokemon.get(handler_type)
		if type != null:
			var handler: Variant = type.get("handler")
			if handler != null:
				var method: Variant = handler.get("on_"+event)
				if typeof(method) == TYPE_CALLABLE: # Make sure it's a Callable
					handlers.push_back(method)
	for flag in battler.battler_flags:
		if battler.battler_flags[flag] is Array and battler.battler_flags[flag][0] is FlagHandler:
			var handler: Variant = battler.battler_flags[flag][0].get("on_"+event)
			if typeof(handler) == TYPE_CALLABLE: # Make sure it's a Callable
				handlers.push_back(handler)
	for flag in battler.side.side_flags:
		if battler.side.side_flags[flag] is Array and battler.side.side_flags[flag][0] is FlagHandler:
			var handler: Variant = battler.side.side_flags[flag][0].get("on_"+event)
			if typeof(handler) == TYPE_CALLABLE: # Make sure it's a Callable
				handlers.push_back(handler)
	return handlers


## [Public] Adds a battle event to be processed later.
func add_battle_event(event: BaseEvent) -> void:
	battle_events.push_back(event)


## [Public] Runs a battle event immediately and waits for event_handled signal to be emitted.
func run_battle_event(event: BaseEvent) -> void:
	SignalBus.battle_event.emit(event)
	await SignalBus.event_handled


## [Private] Calculates priority, emits turn_started and changes state to ATTACKING_PHASE
func _play_turn():
	_calculate_priority()
	SignalBus.turn_started.emit()
	_change_state(STATE.ATTACKING_PHASE)


## [Private] Calculates priority of different actions and adds them to battle_actions
## The actions are in reverse so pop_back can be used to execute them later
func _calculate_priority(is_mid_turn: bool = false) -> void:
	var action_priority_entry: Array = []
	for action in battle_actions:
		var order: int = action.get_action_order()
		if action is SwitchAction:
			action_priority_entry.push_back([action, order, 0, action.switch_in.get_calculated_speed()])
		elif action is MoveAction:
			var move_priority: int = action.move.handler.move_priority()
			var battler_speed: int = action.user.get_calculated_speed()
			var sub_priority: int = 0
			if not is_mid_turn:
				var ability_priority: int = action.user.pokemon.ability.handler.on_priority_bracket_change(self, action.user, action.original_target, action.move)
				var item_priority: int = 0
				if ability_priority <= 0:
					item_priority = action.user.pokemon.item.handler.on_priority_bracket_change(self, action.user, action.original_target, action.move)
				sub_priority = ability_priority + item_priority
			var priority_modifiers = run_action_event("modify_priority", action.user, null, [self, action.user, action.move])
			for priority in priority_modifiers:
				move_priority += priority
			action_priority_entry.push_back([action, order, move_priority + sub_priority, battler_speed])
	
	# Sort in reverse so push/pop_back can be used 
	action_priority_entry.sort_custom(func(a, b) -> bool:
		if a[1] != b[1]:
			return !_compare_values(a[1], b[1])
		elif a[2] != b[2]:
			return !_compare_values(a[2], b[2])
		return !_compare_values(a[3], b[3])
	)
	battle_actions.clear() # Clear any previous actions that may linger
	for entry in action_priority_entry:
		battle_actions.push_back(entry[0])


## [Private] Changes state for new_state and emits state_changed
## If new_state is the current state, the signal is not emitted
func _change_state(new_state: STATE) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(state)


## [Private] Calls the appropiate function depending on state
func _on_state_changed(new_state: STATE):
	if new_state == STATE.COMMAND_PHASE:
		_command_phase()
	elif new_state == STATE.ATTACKING_PHASE:
		_attacking_phase()
	elif new_state == STATE.PROCESSING_EVENTS:
		_battle_events_processing_phase()
	elif new_state == STATE.END_TURN_PHASE:
		_end_turn_phase()


## [Private] Goes through each battler and awaits for it to choose an action (if it can)
## After all actions are chosen, it calls _play_turn()
func _command_phase():
	# TODO: Go through all sides and check if battler is Player or AI controlled
	# TODO: Implement AI to choose moves. This is temporary for testing
	var choosable_moves = Constants.moves.keys()
	for foe in sides[1].active:
		if foe not in sides[1].battlers_actioned:
			if foe.can_choose_action(true):
				if foe == sides[1].active[0]:
					queue_move(Constants.get_move_by_id(choosable_moves.pick_random()), foe, sides[0].active.pick_random())
				else:
					queue_move(Constants.get_move_by_id(choosable_moves.pick_random()), foe, sides[0].active.pick_random())
	while true:
		var index: int = sides[0].current_battler_index
		if index < 0 or index >= len(sides[0].active):
			print("Invalid battler index to choose command")
			break
		var battler: Battler = sides[0].active[index]
		if battler.can_choose_action(true):
			SignalBus.battler_ready.emit(battler)
			while true:
				await action_chosen
				break
				
			if len(sides[0].battlers_actioned) >= len(sides[0].active):
				break
	sides[1].battlers_actioned.clear()
	sides[0].battlers_actioned.clear()
	sides[0].current_battler_index = 0
	_play_turn()


## [Private] Goes through each battle_action and executes it
## It changes the state to PROCESSING_EVENTS after each action and to END_TURN_PHASE after all actions have been executed
func _attacking_phase():
	print("\n\n\n")
	if len(battle_actions) <= 0:
		_change_state(STATE.END_TURN_PHASE)
		return
	var action = battle_actions.pop_back()
	action.execute()
	add_battle_event(ChangeStateEvent.new(STATE.ATTACKING_PHASE))
	_change_state(STATE.PROCESSING_EVENTS)


## [Private] Goes through each battle_event and executes it
## It awaits any signal provided and pauses for the specified time in the event's post_await property
func _battle_events_processing_phase():
	var will_change_state: bool = false
	var next_state: STATE
	while not battle_events.is_empty():
		var event: BaseEvent = battle_events.pop_front()
		
		# Without this, the state is changed and it messes up everything the next time this loop runs.
		# It is assumed that the change of state is the last event (and it should be)
		if event is ChangeStateEvent:
			will_change_state = true
			next_state = event.state
			break
			
		await run_battle_event(event)
			
	if will_change_state:
		will_change_state = false
		_change_state(next_state)


## [Private] Runs every residual handler on each active battler
## It emits turn_ended signal at the end
func _end_turn_phase():
	# Residual - May have to refactor
	var active_battlers: Array[Battler] = []
	for side in sides:
		active_battlers.append_array(side.active)
	for active in active_battlers:
		if not active.is_fainted():
			run_action_event("residual", active, null, [self, active])
			
	# TODO: Include AI switches (when AI is able to switch)
	if len(faint_queue) > 0:
		var possible_switches: int = 0
		for battler in sides[0].battlers:
			if battler.can_switch_in(false):
				possible_switches += 1
		for fainted in faint_queue:
			# TODO: Actually check for player side if necessary, depending on how AI is implemented.
			if fainted.side == sides[0] and possible_switches > 0:
				add_battle_event(RequestSwitchEvent.new(self, fainted, true))
				possible_switches -= 1
		faint_queue.clear()
	add_battle_event(ChangeStateEvent.new(STATE.COMMAND_PHASE))
	_change_state(STATE.PROCESSING_EVENTS)
	for side in sides:
		for battler in side.battlers:
			battler.switched_in_this_turn = false
	turn_ended.emit(sides[0].active, sides[1].active)


## [Public] Gets targets depending on the move being used and the type of battle
func get_move_targets(user: Battler, target_type: Constants.MOVE_TARGET) -> Array[Battler]:
	var targets: Array[Battler] = []
	match target_type:
		Constants.MOVE_TARGET.ALL:
			for side in sides:
				targets += side.active
		Constants.MOVE_TARGET.ALL_ADJACENT:
			if len(user.side.active) > 1:
				targets = user.get_adjacent_allies() 
			targets += user.get_adjacent_foes()
		Constants.MOVE_TARGET.ALL_ADJACENT_FOES:
			targets = user.get_adjacent_foes()
		Constants.MOVE_TARGET.ALL_ALLIES:
			targets = user.side.get_allies(user)
		Constants.MOVE_TARGET.SINGLE_BUT_USER:
			for side in sides:
				for battler in side.active:
					if not battler.is_fainted() and not battler.id == user.id:
						targets += [battler]
		# ALLY_TEAM
		# FIELD
		# FOE_SIDE
		Constants.MOVE_TARGET.SINGLE_ADJACENT, Constants.MOVE_TARGET.SINGLE_ADJACENT_FOE:
			targets += user.get_adjacent_foes()
			targets += user.get_adjacent_allies()
		Constants.MOVE_TARGET.SINGLE_ADJACENT_ALLY:
			targets += user.get_adjacent_allies()
		Constants.MOVE_TARGET.USER, Constants.MOVE_TARGET.OTHER, Constants.MOVE_TARGET.RANDOM_ADJACENT:
			targets = [user]
	return targets


## [Public] Gets the opposite side from the one provided
func get_oppossite_side(side: Side) -> Side:
	if sides[0] == side:
		return sides[1]
	return sides[0]


## [Public] Generates a random number between 0 and x-1
func random(x: int) -> int:
	return prng.randi() % x


## [Public] Generates a random number between a min and max (both inclusive)
func random_range(minimum: int, maximum: int) -> int:
	return prng.randi_range(minimum, maximum)
	

## [Private] Compares a and b
## Returns true if a > b, false if a < b or random true/false if they are equal
func _compare_values(a, b) -> bool:
	if a > b:
		return true
	elif a == b:
		return [true, false].pick_random()
	return false


## [Internal] An event to change states, to be added to battle_events instead of
## executing immediately.
class ChangeStateEvent extends BaseEvent:
	var state: STATE
	func _init(next_state: STATE):
		state = next_state

	func _to_string():
		return "Change State Event"
