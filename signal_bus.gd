extends Node

## Battle signals
signal battle_started(user_side_active, user_side_team, foe_side_active, foe_side_team) ## Emitted when the battle is setup and starts
signal battle_ended(win: bool) ## Emitted when the battle ends
signal battler_ready(battler: Battler) ## Emitted when battler must choose an action
signal turn_started() ## Emitted when a new turn starts
signal turn_ended(side_a_team, side_b_team) ## Emitted after all actions are executed
signal battle_event(event: BaseEvent) ## Emitted for each battle event in a turn
signal event_handled() ## Emitted when a battle event is finished
signal ability_activated(event: AbilityEvent) ## Emitted when an ability activates
signal pokemon_changed(switched_out: Battler, switched_in: Battler, index_out: int, index_in: int) ## Emitted when a battler switches in

signal input_paused(paused: bool) ## Emitted when input should be paused or unpaused

signal zone_changed(path: String) ## Emitted when entering a new zone (scene)
