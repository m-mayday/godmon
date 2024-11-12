extends Control
## Databox of a Pokemon during battle
## Displays things like Name, Level, HP, etc.

## Emitted when an animation finishes
signal animation_finished

enum DATABOX_SIDE_TYPE {ALLY, FOE} ## Determines the "direction" of the texture to use
enum DATABOX_SIZE {NORMAL, THIN} ## Determines which size the databox is (Normal is used in single battles for the player only)

## Colors to use according to the battler's HP.
## HP > 50% = Green. HP > 20% and <= 50% = Yellow. HP <= 20% = Red
var _hp_progress_color: Array[Color] = [Color("70f8a8"), Color("f8e038"), Color("f85838")]

## Indicates if the HP bar should be animated when HP changes
## False is typically used when a Pokemon enters battle
var _animate: bool = false

var _battler_side: DATABOX_SIDE_TYPE ## This databox side

var _tween: Tween ## Tween to animate this databox when battler is choosing an action
var _original_position: Vector2 ## Original position to reset it after battler has taken action
var _is_choosing_action: bool ## Indicates if this databox's battler is the one currently choosing an action

## Battler whose data is displayed in this databox
var _battler: Battler:
	set(value):
		_battler = value
		_update_data(_battler.pokemon.current_hp)

@onready var _bottom_texture = $Bottom
@onready var _bottom_texture_thin = $BottomThin
@onready var _hp_bar = $StatusContainer/HBoxContainer/HPTexture/HPBar


func _ready():
	add_to_group("battlers")
	SignalBus.health_changed.connect(_on_health_changed)
	SignalBus.pokemon_changed.connect(_on_switched_in)
	SignalBus.battler_ready.connect(_on_battler_ready)
	SignalBus.pokemon_status_set.connect(_on_status_set)
	SignalBus.turn_started.connect(_kill_tween)


## Initializes this node with a side type, size and battler
func init(p_type: DATABOX_SIDE_TYPE, p_size: DATABOX_SIZE, p_battler: Battler) -> void:
	if p_size == DATABOX_SIZE.THIN:
		_bottom_texture.hide()
		$HPContainer.hide()
		$ExpTexture.hide()
		_bottom_texture_thin.show()
		custom_minimum_size = Vector2(_bottom_texture_thin.size.x, _bottom_texture_thin.size.y + $Top.size.y)
	if p_type == DATABOX_SIDE_TYPE.ALLY:
		# Flip the textures
		_bottom_texture.scale.x = -1
		_bottom_texture_thin.scale.x = -1
	_battler_side = p_type
	_battler = p_battler
	_animate = true


## Updates the Pokemon's HP
func _on_health_changed(event: HealthChangedEvent) -> void:
	if _battler == null:
		return
	if _battler.id == event.pokemon.id:
		if _animate:
			event.await_signals.push_back(animation_finished)
		_update_data(event.new_hp)


## Plays the specified animation if it corresponds to this battler and is one of the expected animations
func play_animation(event: AnimationEvent) -> void:
	if event.animation == "" or event.battler == null:
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


## Changes to the new active battler in this position when the current one leaves battle
func _on_switched_in(switched_out: Battler, switched_in: Battler, _index_out: int, _index_in: int, _action: BaseEvent = null) -> void:
	if _battler == null:
		return
	var is_animating: bool = _animate
	_animate = false
	if switched_out.id == _battler.id:
		_battler = switched_in
		_set_hp_bar_color(_battler.pokemon.current_hp)
	_animate = is_animating


## Updates the data displayed to reflect any changes (i.e.: HP increase/decrease, battler change, etc.)
func _update_data(new_health) -> void:
	if _battler != null:
		%Lv.text = str(_battler.pokemon.level)
		$MarginContainer/HBoxContainer/Name.text = _battler.pokemon.name
		if $HPContainer.visible:
			$HPContainer/HP.text = "{0} / {1}".format([new_health, _battler.pokemon.stats.hp])
		
		_hp_bar.max_value = _battler.pokemon.stats.hp
		if _animate:
			var tween: Tween = get_tree().create_tween()
			tween.set_parallel()
			tween.tween_method(_set_hp_label, _hp_bar.value, new_health, 0.5)
			tween.tween_property(_hp_bar, "value", new_health, 0.5)
			tween.play()
			await tween.finished
			_set_hp_bar_color(new_health)
		else:
			_hp_bar.value = _battler.pokemon.current_hp


## Sets the status texture if battler has a status
func _on_status_set(event: StatusSetEvent) -> void:
	if event.pokemon.id == _battler.id:
		%Status.texture = event.status.icon
		%Status.visible = event.status.icon != null


## Sets the new HP. Used to tween the value increasing/decreasing
func _set_hp_label(value: int) -> void:
	if $HPContainer.visible:
		$HPContainer/HP.text ="{0} / {1}".format([value, _battler.pokemon.stats.hp])


## Called when the HP bar tween finishes. It changes the color of the HP bar and emits animation_finished signal
func _set_hp_bar_color(new_health: int) -> void:
	var hp_percentage := float(new_health) / float(_battler.pokemon.stats.hp)
	if hp_percentage > 0.5:
		_hp_bar.tint_progress = _hp_progress_color[0]
	elif hp_percentage > 0.2 && hp_percentage <= 0.5:
		_hp_bar.tint_progress = _hp_progress_color[1]
	else:
		_hp_bar.tint_progress = _hp_progress_color[2]
	animation_finished.emit()


## Animates this databox moving up and down until its battler chooses an action in battle
func _on_battler_ready(current_battler: Battler) -> void:
	_kill_tween()
	_is_choosing_action = false
	if _battler == current_battler:
		_is_choosing_action = true
		_original_position = position
		_tween = create_tween()
		_tween.set_loops()
		_tween.tween_property(self, "position:y", -3, 0.3).as_relative()
		_tween.tween_property(self, "position:y", 3, 0.3).as_relative()
		_tween.play()


## Kills the _tween to stop any looping animations
func _kill_tween() -> void:
	if _tween:
		_tween.kill()
		position = _original_position


## Tweens this databox if its battler is the current target being chosen
func on_choosing_targets(targets: Array[Battler], _move: Move) -> void:
	_kill_tween()
	if _battler in targets:
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
