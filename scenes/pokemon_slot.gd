extends PanelContainer
## Won't document since it's a placeholder

enum CONTEXT {MENU, BATTLE}

var context: CONTEXT = CONTEXT.MENU

var battler: Battler:
	set(value):
		pokemon = value.pokemon
		battler = value
		update_slot()
var pokemon: Pokemon:
	set(value):
		pokemon = value
		update_slot()

var animate: bool = true

signal animation_finished

func _ready():
	SignalBus.health_changed.connect(_on_health_changed)
	SignalBus.pokemon_changed.connect(_on_switched_in)

func _on_health_changed(event: HealthChangedEvent):
	if pokemon == null: return
	if pokemon.id == event.pokemon.id:
		pokemon = event.pokemon
		
func _on_switched_in(switched_out: Battler, switched_in: Battler, _index_out: int, _index_in: int, _action: BaseEvent = null):
	if pokemon == null: return
	var is_animating = animate
	animate = false
	if switched_out.id == pokemon.id:
		battler = switched_in
	animate = is_animating

func update_slot():
	if pokemon != null:
		$VBoxContainer/Name.text = pokemon.name
		$VBoxContainer/HBoxContainer/HPLabel.text = "{0} / {1}".format([pokemon.current_hp, pokemon.stats.hp])
		$VBoxContainer/HBoxContainer/StatusLabel.text = pokemon.status.name
		$VBoxContainer/HPBar.max_value = pokemon.stats.hp
		if animate:
			var tween = get_tree().create_tween()
			tween.finished.connect(_on_tween_finished)
			tween.set_parallel()
			tween.tween_method(set_hp_label, $VBoxContainer/HPBar.value, pokemon.current_hp, 0.5)
			tween.tween_property($VBoxContainer/HPBar, "value", pokemon.current_hp, 0.5)
			tween.play()
		else:
			$VBoxContainer/HPBar.value = pokemon.current_hp

func set_hp_label(value: int):
	$VBoxContainer/HBoxContainer/HPLabel.text="{0} / {1}".format([value, pokemon.stats.hp])

func _on_tween_finished():
	animation_finished.emit()
