extends Control
## Back/Front sprite of Pokemon in battle
## Includes shadow and animations

signal animation_finished

enum SPRITE_TYPE { BACK, FRONT } ## If it's a back sprite (Player) or front sprite (Foe)

var battler: Battler: ## The battler to represent with this sprite
	set(value):
		battler = value
		_update_sprite()

var _sprite_type: SPRITE_TYPE = SPRITE_TYPE.BACK ## The current _sprite_type
var _action_tween: Tween ## Tween to animate this battler when choosing an action
var _target_tween: Tween ## Tween to animate this battler when choosing a target
var _original_position: Vector2 ## Original position to reset it after battler has taken action

@onready var _animator: AnimationPlayer = $AnimationPlayer


func _ready():
	add_to_group("battlers")
	SignalBus.pokemon_changed.connect(_on_pokemon_changed)
	SignalBus.battler_ready.connect(_on_battler_ready)
	SignalBus.turn_started.connect(_kill_action_tween)
	_update_sprite()
	_animator.play("send_out")


## Initializes this node with a _sprite_type and battler
func init(p_sprite_type: SPRITE_TYPE, p_battler: Battler) -> void:
	if p_battler == null:
		return
	_sprite_type = p_sprite_type
	if _sprite_type == SPRITE_TYPE.BACK:
		$Shadow.hide()
	battler = p_battler


## Animates this battler switching out and changes battler to the one switching in
func _on_pokemon_changed(switched_out: Battler, switched_in: Battler, _index_out: int, _index_in: int, _action: BaseEvent = null) -> void:
	if switched_out.id == battler.id:
		battler = switched_in


## Plays the specified animation if it corresponds to this battler and exists in this battler's AnimationPlayer
func play_animation(event: AnimationEvent) -> void:
	if event.animation == "" or event.battler == null:
		return
	if battler.id != event.battler.id or not _animator.has_animation(event.animation):
		return
	event.await_signals.push_back(_animator.animation_finished)
	_animator.play(event.animation)
	#await _animator.animation_finished
	#animation_finished.emit()


## Updates the sprite's texture, offset and scale, depending on type sprite and battler species
func _update_sprite() -> void:
	var sprite: Sprite2D = $Sprite
	var pokemon: Species = battler.pokemon.species
	match _sprite_type:
		SPRITE_TYPE.BACK:
			sprite.texture = pokemon.back_sprite
			sprite.offset = pokemon.sprite_metrics.back_sprite_offset
			sprite.scale = pokemon.sprite_metrics.back_sprite_scale
		SPRITE_TYPE.FRONT:
			sprite.texture = pokemon.front_sprite
			sprite.offset = pokemon.sprite_metrics.front_sprite_offset
			sprite.scale = pokemon.sprite_metrics.front_sprite_scale
			$Shadow.scale = pokemon.sprite_metrics.shadow_scale
			$Shadow.offset = Vector2(pokemon.sprite_metrics.shadow_offset.x, sprite.texture.get_height() / 2 + pokemon.sprite_metrics.shadow_offset.y)
	_set_animation_scale("call_back", 2, 0)
	_set_animation_scale("call_back", 2, 1, Vector2(0, $Sprite.scale.y))
	_set_animation_scale("send_out", 2, 1)


## Shows shadow when battler is sent out (if it's a foe battler)
func _on_send_out_animation_finished() -> void:
	if _sprite_type == SPRITE_TYPE.FRONT:
		$Shadow.show()


## Adjusts animation scaling for the provided animation (sending out or calling back battler) and track
func _set_animation_scale(animation: String, track: int, key: int, value: Vector2 = $Sprite.scale) -> void:
	# Adjust animation scaling
	if _animator == null:
		return
	var anim: Animation = _animator.get_animation(animation)
	anim.track_set_key_value(track, key, value) # Track index (scale), Key index (last one), Value


## Animates this battler moving up and down until an action is chosen in battle
func _on_battler_ready(current_battler: Battler) -> void:
	_kill_action_tween()
	if battler == current_battler:
		_original_position = position
		_action_tween = create_tween()
		_action_tween.set_loops()
		_action_tween.tween_property(self, "position:y", 3, 0.3).as_relative()
		_action_tween.tween_property(self, "position:y", -3, 0.3).as_relative()
		_action_tween.play()


## Kills the _action_tween to stop any looping animations
func _kill_action_tween() -> void:
	if _action_tween:
		_action_tween.kill()
		position = _original_position


## Kills the _target_tween to stop any looping animations
func _kill_target_tween() -> void:
	if _target_tween:
		_target_tween.kill()
		modulate.a = 1.0


## Tweens this battler if is the current target being chosen
func on_choosing_targets(current_targets: Array[Battler], _move: Move) -> void:
	_kill_target_tween()
	if battler in current_targets:
		_target_tween = create_tween()
		_target_tween.set_loops()
		_target_tween.tween_property(self, "modulate:a", 0, 0.2)
		_target_tween.tween_property(self, "modulate:a", 1.0, 0.2)
		_target_tween.play()


## Cancels the tween when this battler is no longer being chosen
func cancel_target_choosing() -> void:
	_kill_target_tween()
