extends Node
## The (visual) battle scene

signal enter ## Emitted when the user presses enter

@export var player_single_databox: Resource ## The databox used only by the player on single battles
@export var pokemon_databox: Resource ## The databox node to use
@export var pokemon_sprite: Resource ## The sprite node to use
@export var party_screen: CanvasLayer ## Party screen for switches
@export var message_box: NinePatchRect ## The box where messages are displayed
@export var message_balloon: CanvasLayer ## Balloon to use to show messages

## The different menus in battle
@export var _fight_menu: Control
@export var _battle_menu: NinePatchRect
@export var _target_menu: NinePatchRect

@export var animator: AnimationPlayer

var _battle: Battle ## Reference to the current battle
var _ui_stack: Array[Control] = [] ## Stack of menus (Choose action, choose move, choose target, etc.)
var _current_battler: Battler ## Current battler choosing an action


var text_advance_arrow_path: String = "res://Assets/Battle/UI/text_advance_arrow.png" # I will leave this like so for now
	
func with_data(data: Array) -> void:
	assert(len(data) == 3, "Wrong number of parameters in battle scene")
	var battle_type: String = data[0]
	var _first_trainer: Area2D = data[1] # For now, until Trainer class is created
	var _second_trainer: Area2D = null # For now, until Trainer class and trainer battles are created
	var wild_pokemon: Array[Pokemon] = []
	if battle_type == "wild":
		assert(data[2] is Array, "An array of Pokemon must be provided for wild battle")
		for pokemon in data[2]:
			wild_pokemon.append(pokemon)

	SignalBus.battle_started.connect(_on_battle_started)
	SignalBus.battle_ended.connect(_on_battle_end)
	SignalBus.turn_started.connect(_on_turn_started)
	SignalBus.battler_ready.connect(_set_current_battler)
	SignalBus.battle_event.connect(_on_battle_event)
	SignalBus.turn_ended.connect(_target_menu.on_turn_ended)
	party_screen.screen_closed.connect(_on_party_screen_closed)
	_battle = Battle.new(Global.player_party, wild_pokemon, Constants.BATTLE_SIZE.TRIPLE)
	_fight_menu.move_chosen.connect(_target_menu.on_move_chosen)
	_target_menu.target_chosen.connect(_on_target_chosen)
	_battle.battle_start() # Start the battle


func _on_battle_event(event: BaseEvent, emit_handled_signal: bool = true) -> void:
	if event is BattleStartEvent:
			await _on_battle_started(event)
	elif event is BattleDialogueEvent:
		_display_battle_message(event.text, null, event.should_wait_input)
		await DialogueManager.dialogue_ended
		if event.should_wait_input:
			await enter
	elif event is AnimationEvent:
		get_tree().call_group("battlers", "play_animation", event)
		await _await_event_signals(event)
	elif event is HealthChangedEvent:
		get_tree().call_group("battlers", "health_changed", event)
		await _await_event_signals(event)
	elif event is StatusSetEvent:
		get_tree().call_group("battlers", "status_set", event)
		await _await_event_signals(event)
	elif event is RequestSwitchEvent:
		message_balloon.hide()
		party_screen.request_switch(event)
		await _await_event_signals(event)
	elif event is SwitchEvent:
		await _on_battler_switched(event)
	elif event is FaintEvent:
		await _on_battle_event(AnimationEvent.new("faint", [event.battler]), false)
		_display_battle_message("{0} fainted!".format([event.battler.pokemon.name]), null, true)
		await DialogueManager.dialogue_ended
		await enter
	elif event is AbilityEvent:
		get_tree().call_group("ability", "ability_activated", event)
		await _await_event_signals(event)
	
	if event.post_await > 0.0:
		await get_tree().create_timer(event.post_await).timeout

	if emit_handled_signal:
		SignalBus.event_handled.emit()


func _await_event_signals(event: BaseEvent) -> void:
	if len(event.await_signals) > 0:
		for wait_signal: Signal in event.await_signals:
			# Instances can be null, like tweens for example
			if is_instance_valid(wait_signal.get_object()) and not wait_signal.is_null():
				await wait_signal
	else:
		await get_tree().process_frame # Workaround. For some reason, if you don't await anything, the battle script stops handling events


func _input(event):
	if event.is_action_released("interact"):
		enter.emit()
	elif event.is_action_pressed("cancel"):
		if _ui_stack.size() > 1:
			_pop_menu()
		elif _current_battler != null:
			_battle.unqueue_action(_current_battler.side)


func _on_turn_started() -> void:
	_pop_menu()


## Passes the current battler to some nodes
func _set_current_battler(battler: Battler) -> void:
	_current_battler = battler
	_display_battle_message("What will {0} do?".format([battler.pokemon.name]), null, false, true)
	_push_menu(_battle_menu)


## Does some setup when battle is started
func _on_battle_started(event: BattleStartEvent) -> void:
	var active_user: Array[Battler] = event.get_player_side_active()
	var active_foe: Array[Battler] = event.get_opponent_side_active()
	_setup_side(active_foe, false) # TODO: Only do this setup if it's a wild battle
	_target_menu.on_turn_ended(active_user, active_foe)
	animator.queue("transition")
	animator.queue("battleback")
	await animator.animation_changed
	await animator.animation_finished
	_display_battle_message("A group of wild Pokemon appeared!", null, true)
	await DialogueManager.dialogue_ended
	var names: String = active_user[0].pokemon.name
	if len(active_user) > 1:
		names += ", "
		for index in range(1, active_user.size()):
			if index == len(active_user)-1:
				names += active_user[index].pokemon.name
			else:
				names += active_user[index].pokemon.name + ", "
	names += "!"
	_display_battle_message("Go! " + names)
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(0.5).timeout
	animator.play("trainer_send_out")
	await animator.animation_finished
	_setup_side(event.get_player_side_active(), true)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($UserSide/Databoxes, "position:x", 784 - $UserSide/Databoxes.position.x, 0.5).as_relative()
	tween.play()
	await tween.finished


func _on_battler_switched(event: SwitchEvent) -> void:
	if not event.switch_out.is_fainted():
		_display_battle_message("{0} come back!".format([event.switch_out.pokemon.name]))
		await DialogueManager.dialogue_ended
		await _on_battle_event(AnimationEvent.new("call_back", [event.switch_out]), false)
	_display_battle_message("Go {0}!".format([event.switch_in.pokemon.name]))
	await DialogueManager.dialogue_ended
	SignalBus.pokemon_changed.emit(event.switch_out, event.switch_in, event.switch_out.get_team_position(), event.switch_in.get_team_position())
	await _on_battle_event(AnimationEvent.new("send_out", [event.switch_in]), false)


## Creates the sprites and databoxes for a side depending on is_player_side value
func _setup_side(battlers: Array[Battler], is_player_side: bool) -> void:
	for battler in battlers:
		match is_player_side:
			true:
				# Create databox
				var databox: Control
				if len(battlers) > 1:
					databox = pokemon_databox.instantiate()
				else:
					databox = player_single_databox.instantiate()
				databox.size_flags_horizontal = databox.SIZE_SHRINK_END
				databox.size_flags_vertical = databox.SIZE_SHRINK_END
				databox.size_flags_vertical += databox.SIZE_EXPAND
				$UserSide/Databoxes.add_child(databox)
				databox.with_data(databox.DATABOX_SIDE_TYPE.ALLY)
				
				# Create sprite
				var sprite: Control = pokemon_sprite.instantiate()
				sprite.size_flags_horizontal = sprite.SIZE_SHRINK_CENTER
				sprite.size_flags_horizontal += sprite.SIZE_EXPAND
				$UserSide/Sprites.add_child(sprite)
				sprite.with_data(sprite.SPRITE_TYPE.BACK)
				
			false:
				# Create databox
				var databox: Control = pokemon_databox.instantiate()
				databox.size_flags_horizontal = databox.SIZE_SHRINK_BEGIN
				databox.size_flags_vertical = databox.SIZE_SHRINK_BEGIN
				$FoeSide/Databoxes.add_child(databox)
				databox.with_data(databox.DATABOX_SIDE_TYPE.FOE)
				
				# Create sprite
				var sprite: Control = pokemon_sprite.instantiate()
				sprite.size_flags_horizontal = sprite.SIZE_SHRINK_CENTER
				sprite.size_flags_horizontal += sprite.SIZE_EXPAND
				$FoeSide/Sprites.add_child(sprite)
				sprite.with_data(sprite.SPRITE_TYPE.FRONT)


## Displays a battle message
func _display_battle_message(message: String, action: BattleDialogueEvent = null, wait_input: bool = false, instant:bool = false) -> void:
	message_balloon.show()
	var text = "~ start\n"+message
	if (action != null and action.should_wait_input) or wait_input:
		text += "[icon]"
	else:
		text += "[next=0.4]"
	text += "\n=> END"
	var resource = DialogueManager.create_resource_from_text(text)
	message_balloon.start(resource, "start")
	if instant:
		message_balloon.dialogue_label.skip_typing()


## Pushes the fight menu in the ui_stack
func _on_battle_menu_fight_pressed() -> void:
	_push_menu(_fight_menu)
	message_balloon.hide()


## Pushes the target menu in the ui_stack
func _on_fight_menu_move_chosen(move: Move) -> void:
	if _battle.battle_size == Constants.BATTLE_SIZE.NORMAL:
		_on_target_chosen(null, move) # Chosen target doesn't matter, battle will correct it
		return
	var targets: Array[Battler] = _battle.get_move_targets(_current_battler, move.target)
	if len(targets) <= 0:
		return
	_target_menu.targets = targets
	_push_menu(_target_menu)


## Queues the chosen move in battle after a target is chosen
func _on_target_chosen(target: Battler, move: Move) -> void:
	_battle.queue_move(move, _current_battler, target)
	_pop_menu()
	_pop_menu()


## Open up the Pokemon Party Menu
func _on_battle_menu_switch_pressed() -> void:
	set_process_input(false)
	_battle_menu.hide() # To show when screen is closed, so it regrabs focus of the last option
	party_screen.show()
	

## Close the Pokemon Party Menu
func _on_party_screen_closed() -> void:
	party_screen.hide()
	_battle_menu.show()
	set_process_input(true)


## Queues the chosen pokemon switch in battle
func _on_pokemon_menu_switch(switch_out: Battler, switch_in: Battler, is_instant_switch: bool) -> void:
	_battle.queue_switch(switch_out, switch_in, is_instant_switch)
	party_screen.hide()
	set_process_input(true)


## Queues action to try to escape from battle
func _on_battle_menu_run_pressed() -> void:
	var run_message: String = _battle.can_escape(_current_battler)
	if run_message == "":
		_battle.queue_escape(_current_battler)


## Pushes a menu into the ui_stack if it's not in it yet
func _push_menu(control: Control) -> void:
	if not _ui_stack.is_empty():
		_ui_stack.back().hide()
	if control not in _ui_stack:
		_ui_stack.push_back(control)
	control.show()


## Pops the last menu in the ui_stack
func _pop_menu() -> void:
	if _ui_stack.is_empty():
		return
	var pop_ui: Control = _ui_stack.pop_back()
	pop_ui.hide()
	if not _ui_stack.is_empty():
		_ui_stack.back().show()
	if pop_ui == _target_menu:
		get_tree().call_group("battlers", "cancel_target_choosing")
	elif pop_ui == _fight_menu:
		_display_battle_message("What will {0} do?".format([_current_battler.pokemon.name]), null, false, true)
		message_box.show()


## Returning to previous scene when battle ends
func _on_battle_end(win: bool) -> void:
	if win:
		get_tree().root.get_node("Main").return_to_previous_scenes()
