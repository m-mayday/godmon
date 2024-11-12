extends PanelContainer
## Won't document since it's a placeholder

enum CONTEXT {
	PARTY,
	BATTLE,
}

signal switch(switch_out, switch_in, is_instant_switch)

@export var context: CONTEXT = CONTEXT.PARTY
@onready var slot_container = $MarginContainer/HBoxContainer/VBoxContainer
@onready var arrow = $MarginContainer/HBoxContainer/Arrow
var battlers: Array
var pokemon: Array
var switch_out: Battler
var instant_switch: bool = false
var selected_option: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.pokemon_changed.connect(_on_battle_switch)

func setup(p_pokemon: Array):
	if context == CONTEXT.BATTLE:
		battlers.assign(p_pokemon)
		for battler in battlers:
			pokemon.push_back(battler.pokemon)
	else:
		pokemon.assign(p_pokemon)
	update()

func set_current_battler(battler: Battler):
	switch_out = battler


func request_switch(event: RequestSwitchEvent):
	show()
	switch_out = event.battler
	instant_switch = event.is_instant_switch


func _on_battle_switch(switched_out: Battler, switched_in: Battler, index_out: int, index_in: int, _action: BaseEvent = null):
	battlers[index_out] = switched_in
	battlers[index_in] = switched_out
	pokemon[index_out] = switched_in.pokemon
	pokemon[index_in] = switched_out.pokemon
	update()
	
func update():
	if len(pokemon) <= 0: return
	selected_option = 0	
	var slots: Array[Node] = slot_container.get_children()
	for i in len(pokemon):
		slots[i].pokemon = pokemon[i]
		slots[i].modulate.a = 1

func _on_visibility_changed():
	if slot_container == null: return
	if !visible: return
	selected_option = 0
	var slots: Array[Node] = slot_container.get_children()
	if slots[0].animate:
		for slot in slots:
			if slot is Label: continue
			slot.animate = false
	update()

func _input(event):
	if !visible: return
	if event.is_action_pressed("ui_right") || event.is_action_pressed("ui_down"):
		selected_option = posmod(selected_option+1, len(pokemon))
	elif event.is_action_pressed("ui_left") || event.is_action_pressed("ui_up"):
		selected_option = posmod(selected_option-1, len(pokemon))
	elif event.is_action_pressed("ui_accept") && context == CONTEXT.BATTLE:
		var switch_in = battlers[selected_option]
		if switch_in.can_switch_in():
			switch.emit(switch_out, switch_in, instant_switch)
			switch_out = null
		return
	elif event.is_action_pressed("ui_cancel"):
		hide()
	var slot = slot_container.get_child(selected_option)
	arrow.position.y = slot.position.y
