extends Control
## Databox of a Pokemon during battle
## Displays things like Name, Level, HP, etc.

## Emitted when an animation finishes
signal animation_finished

enum DATABOX_SIDE_TYPE {ALLY, FOE} ## Determines the "direction" of the texture to use
enum DATABOX_SIZE {NORMAL, THIN} ## Determines which size the databox is (Normal is used in single battles for the player only)

@export var name_label: Label
@export var level_label: Label
@export var bottom_texture: TextureRect
@export var status_texture: TextureRect
@export var hp_bar: TextureProgressBar
@export var hp_container: MarginContainer ## Optional. Main databox only
@export var hp_label: Label ## Optional. Main databox only
@export var exp_bar: TextureProgressBar ## Optional. Main databox only

## Indicates if the HP bar should be animated when HP changes
## False is typically used when a Pokemon enters battle
var _animate: bool = false

var _battler_side: DATABOX_SIDE_TYPE ## This databox's side

var _tween: Tween ## Tween to animate this databox when battler is choosing an action
var _original_position: Vector2 ## Original position to reset it after battler has taken action
var _is_choosing_action: bool ## Indicates if this databox's battler is the one currently choosing an action

## Battler whose data is displayed in this databox
var _battler: Battler:
	set(value):
		_battler = value
		_set_data()


func _ready():
	add_to_group("battlers")
	SignalBus.pokemon_changed.connect(_on_switched_in)
	SignalBus.battler_ready.connect(_on_battler_ready)
	SignalBus.turn_started.connect(_kill_tween)


## Initializes this node with a side type
func with_data(p_type: DATABOX_SIDE_TYPE) -> void:
	if p_type == DATABOX_SIDE_TYPE.ALLY:
		_battler = Global.get_player_battler(get_index())
		bottom_texture.scale.x = -1  # Flip the texture
	else:
		_battler = Global.get_foe_battler(get_index())
	_battler_side = p_type
	_animate = true


## Plays the specified animation if it corresponds to this battler and is one of the expected animations
func play_animation(event: AnimationEvent) -> void:
	if event.animation == "" or event.battler == null or _battler == null:
		return
	if event.animation not in ["call_back", "send_out", "faint"] or _battler.id != event.battler.id:
		return
	var direction: int = 1 
	if _battler_side != DATABOX_SIDE_TYPE.ALLY:
		direction = -1
	var tween: Tween = get_tree().create_tween()
	event.await_signals.push_back(tween.finished)
	match event.animation:
		"call_back", "faint":
			tween.tween_property(self, "position:x", 300 * direction, 0.5).as_relative()
		"send_out":
			tween.tween_property(self, "position:x", 300 * -direction, 0.5).as_relative()
	tween.play()


## Tweens this databox if its battler is the current target being chosen
func on_choosing_targets(targets: Array[Battler], _move: Move) -> void:
	_kill_tween()
	if _battler in targets and not _battler.is_fainted():
		_original_position = position
		_tween = create_tween()
		_tween.set_loops()
		_tween.tween_property(self, "position:y", -3, 0.3).as_relative()
		_tween.tween_property(self, "position:y", 3, 0.3).as_relative()
		_tween.play()


## Cancels the tween when this battler is no longer being chosen and it's not the current one choosing an action
func cancel_target_choosing() -> void:
	if _is_choosing_action:
		_on_battler_ready(_battler)
	else:
		_kill_tween()


## Sets the status texture if battler has a status
func status_set(event: StatusSetEvent) -> void:
	if event.pokemon.id == _battler.id:
		status_texture.texture = event.status.icon
		status_texture.visible = event.status.icon != null
		
		
## Updates the Pokemon's HP
func health_changed(event: HealthChangedEvent) -> void:
	if _battler == null:
		return
	if _battler.id == event.pokemon.id:
		hp_bar.max_value = _battler.pokemon.stats.hp
		if hp_container != null:
			hp_label.text = "{0} / {1}".format([event.new_hp, _battler.pokemon.stats.hp])
		if _animate:
			event.await_signals.push_back(animation_finished)
			var tween: Tween = get_tree().create_tween()
			tween.set_parallel()
			tween.tween_method(_set_hp_label, hp_bar.value, event.new_hp, 0.5)
			tween.tween_property(hp_bar, "value", event.new_hp, 0.5)
			tween.play()
			await tween.finished
			hp_bar.set_hp_bar_progress(event.new_hp, _battler.pokemon.stats.hp)
			animation_finished.emit()
		else:
			hp_bar.value = _battler.pokemon.current_hp


## Animates the battler gaining experience (if there's an experience bar)
func exp_gained(event: ExpGainEvent) -> void:
	if event.pokemon.id == _battler.id and exp_bar != null:
		event.await_signals.push_back(animation_finished)
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(exp_bar, "value", exp_bar.value + event.exp_gained, 0.5)
		tween.play()
		await tween.finished
		animation_finished.emit()


## Updates the level label and sets the new values for the experience bar.
func level_up(event: LevelUpEvent) -> void:
	if event.pokemon.id == _battler.id:
		level_label.text = str(_battler.pokemon.level)
		if hp_label != null:
			hp_label.text = "{0} / {1}".format([_battler.pokemon.current_hp, _battler.pokemon.stats.hp])
		if exp_bar != null:
			exp_bar.min_value = event.pokemon.species.growth_rate.get_level_minimum_exp(event.pokemon.level)
			exp_bar.max_value = event.pokemon.species.growth_rate.get_level_minimum_exp(event.pokemon.level + 1)
			exp_bar.value = event.pokemon.species.growth_rate.get_level_minimum_exp(event.pokemon.level)


## Changes to the new active battler in this position when the current one leaves battle
func _on_switched_in(switched_out: Battler, switched_in: Battler, _index_out: int, _index_in: int, _action: BaseEvent = null) -> void:
	if _battler == null:
		return
	var is_animating: bool = _animate
	_animate = false
	if switched_out.id == _battler.id:
		_battler = switched_in
		hp_bar.set_hp_bar_progress(_battler.pokemon.current_hp, _battler.pokemon.stats.hp)
	_animate = is_animating


## Updates the data displayed to reflect any changes (i.e.: HP increase/decrease, battler change, etc.)
func _update_data(new_health: int) -> void:
	if _battler != null:
		level_label.text = str(_battler.pokemon.level)
		name_label.text = _battler.pokemon.name
		if _battler.pokemon.status.id != Constants.STATUSES.NONE:
			status_texture.texture = _battler.pokemon.status.icon
			status_texture.visible = _battler.pokemon.status.icon != null
		if hp_container != null:
			hp_label.text = "{0} / {1}".format([new_health, _battler.pokemon.stats.hp])
		
		hp_bar.max_value = _battler.pokemon.stats.hp
		if _animate:
			var tween: Tween = get_tree().create_tween()
			tween.set_parallel()
			tween.tween_method(_set_hp_label, hp_bar.value, new_health, 0.5)
			tween.tween_property(hp_bar, "value", new_health, 0.5)
			tween.play()
			await tween.finished
			hp_bar.set_hp_bar_progress(new_health, _battler.pokemon.stats.hp)
			animation_finished.emit()
		else:
			hp_bar.value = _battler.pokemon.current_hp

## Sets the initial data every time the battler changes.
func _set_data() -> void:
	if _battler != null:
		level_label.text = str(_battler.pokemon.level)
		name_label.text = _battler.pokemon.name
		
		if _battler.pokemon.status.id != Constants.STATUSES.NONE:
			status_texture.texture = _battler.pokemon.status.icon
			status_texture.visible = _battler.pokemon.status.icon != null
			
		if hp_container != null:
			hp_label.text = "{0} / {1}".format([_battler.pokemon.current_hp, _battler.pokemon.stats.hp])
		
		hp_bar.max_value = _battler.pokemon.stats.hp
		hp_bar.value = _battler.pokemon.current_hp
		
		if exp_bar != null:
			exp_bar.min_value = _battler.pokemon.species.growth_rate.get_level_minimum_exp(_battler.pokemon.level)
			exp_bar.max_value = _battler.pokemon.species.growth_rate.get_level_minimum_exp(_battler.pokemon.level + 1)
			exp_bar.value = _battler.pokemon.experience

			
## Sets the new HP. Used to tween the value increasing/decreasing
func _set_hp_label(value: int) -> void:
	if hp_container != null:
		hp_label.text ="{0} / {1}".format([value, _battler.pokemon.stats.hp])


## Animates this databox moving up and down until its battler chooses an action in battle
func _on_battler_ready(current_battler: Battler) -> void:
	_kill_tween()
	_is_choosing_action = false
	if _battler == current_battler and not _battler.is_fainted():
		_is_choosing_action = true
		_original_position = position
		_tween = create_tween()
		_tween.set_loops()
		_tween.tween_property(self, "position:y", -3, 0.3).as_relative()
		_tween.tween_property(self, "position:y", 3, 0.3).as_relative()
		_tween.play()


## Kills the _tween to stop any looping animations
func _kill_tween() -> void:
	if _tween and not _battler.is_fainted(): 
		_tween.kill()
		position = _original_position
