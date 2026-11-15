class_name AllyData

extends Resource

enum Rarity
{
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY		
}

@export var id: String = "" #back end name for the ally
@export var name: String = "" #ally name
@export_multiline var description: String = "" #description of the ally for the player
@export var colour: Color = Color(0,0,0,0) #theme colour used for the ally's UI elements

@export var rarity: Rarity #common, uncommon, rare, epic, legendary

@export var base_hp: int = 0 #starting max_hp for the ally
@export var dmg_modifier: int = 0 #starting damage modifier for the ally
@export_range(0.0, 1.0) var acc_modifier: float = 0.0
@export var starting_move: String = "" #id of the move the ally starts with


@export var ability: AbilityData
