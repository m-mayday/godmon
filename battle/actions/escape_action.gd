extends BaseAction
class_name EscapeAction
## Handles the logic of a battler escaping battle

var battle: Battle
var battler: Battler


func _init(p_battler: Battler, p_battle: Battle):
	battler = p_battler
	battle = p_battle


## [Public] Order of action in relation to others.
func get_action_order() -> int:
	return 3


## [Public] Escape calculation
func execute() -> void:
	battler.side.escape_attempts += 1
	var player_speed: int = battler.pokemon.stats.speed
	var foe_speed: int = 1
	for foe in battle.get_oppossite_side(battler.side).active:
		if foe.pokemon.stats.speed > foe_speed:
			foe_speed = foe.pokemon.stats.speed
	if player_speed >= foe_speed:
		battle.add_battle_event(BattleDialogueEvent.new("You got away safely!", [], 0.3, true))
		battle.escaped = true
		return
	var odds: int = int(int(int(player_speed * 32) / int(foe_speed / 4)) + 30 * battler.side.escape_attempts) / 256
	if odds > battle.random(257):
		battle.add_battle_event(BattleDialogueEvent.new("You got away safely!", [], 0.3, true))
		battle.escaped = true
		return
	battle.add_battle_event(BattleDialogueEvent.new("You couldn't get away!", [], 0.3, true))
	return
