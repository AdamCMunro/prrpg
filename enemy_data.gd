class_name EnemyData

extends Resource

@export var id: String = "" #back end name for the enemy
@export var name: String = "" #enemy name
@export_multiline var description: String = "" #description of the enemy for the player

@export var sprite: String = "" #filepath to the enemy sprite

@export var base_hp: int = 0 #max_hp for the enemy

@export var ai : AiData

@export var move_1: String = "" #id of the enemy's first move, empty value means no move
@export var move_2: String = "" #id of the enemy's second move, empty value means no move
