extends Sprite2D
## An ability splash to show in battle when an ability activates

enum ABILITY_SIDE { ALLY, FOE } ## The two sides this node can belong to

## The side this node belongs to, used to adjust its position
@export var side: ABILITY_SIDE = ABILITY_SIDE.ALLY:
	set(value):
		if value == ABILITY_SIDE.FOE:
			region_rect.position.y = 64
			$Name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			$Ability.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		side = value


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.ability_activated.connect(_on_ability_activated)


## Animates the node appearing in the screen, displaying the battler and ability's name
func _on_ability_activated(event: AbilityEvent) -> void:
	if not event.is_ally_side and side == ABILITY_SIDE.ALLY:
		return
	if event.is_ally_side and side == ABILITY_SIDE.FOE:
		return
	$Name.text = event.battler.pokemon.name + "'s"
	$Ability.text = event.ability.name
	var original_position: float = position.x
	var tween: Tween = get_tree().create_tween()
	event.await_signals.push_back(tween.finished)
	tween.tween_property(self, "position:x", max(original_position - region_rect.size.x, 0), 0.5)
	tween.tween_property(self, "position:x", original_position, 0.5).set_delay(0.8)
	tween.play()
