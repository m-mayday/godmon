class_name Species
extends Resource
## Represents a Pokemon species

@export var species_id: Constants.SPECIES ## The species ID
@export var name: StringName = "Unnamed" ## The species name
@export var types: Array[Type] ## The species types
@export var base_stats: Stats = Stats.new() ## The species base stats
@export var base_exp: int = 100 ## The species base experience
@export var evs: Stats ## The species EVs give out
@export_range(0, 255) var catch_rate: int = 255 ## The species catch rate
@export_range(0, 255) var happiness: int = 70 ## The species base happiness
@export var learnset_by_level: Dictionary[int, Learnset] ## The learnset of this pokemon, by level
@export var hatch_steps: int = 1 ## The amount of steps it takes to hatch an egg of this species
@export var height: float = 0.1 ## The species height
@export var weight: float = 0.1 ## The species weight
@export var category: StringName = "???" ## The species category
@export var pokedex: String = "???" ## The species pokedex entry

@export_category("Sprite")
@export var front_sprite: Texture ## The species front sprite
@export var back_sprite: Texture ## The species back sprite in battle
@export var sprite_metrics: SpriteMetrics ## The front and back sprite metrics
