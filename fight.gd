extends Node2D

@onready var squad = get_parent().get_node("Squad")

var fight_over = false
var turn_number = 1

var ally_turn = true
var enemy_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_enemy(enemy: EnemyData, ai: AiData):
	$Enemy.enemy_data = enemy
	$Enemy._populate_enemy_data()
	$Enemy.ai_data = ai

func _start_ally_turn():
	turn_number += 1
	ally_turn = true
	enemy_turn = false
	$EndTurn._slide_in()
	squad._start_turn()
	$TurnLabel/Label.text = "Turn " + str(turn_number)

func _start_enemy_turn():
	ally_turn = false
	enemy_turn = true
	$Enemy._take_turn()

func _show_damage(pos, value):
	$DmgIndicator/Label.text = str(value)
	$DmgIndicator._animate_dmg_label(pos)
	$HitAnimation._play(pos)
	
func _show_heal(pos, value):
	$HealIndicator/Label.text = str(value)
	$HealIndicator._animate_heal_label(pos)

func _show_miss(pos):
	$MissIndicator._animate_miss_label(pos)

func _show_defending(pos):
	$DefendAnimation._play(pos)

func _get_tension():
	return $TensionBar.value

func _set_tension(value):
	$TensionBar._update_value(value)

func _show_invalid_label(text):
	$InvalidLabel/Label.text = text
	$InvalidLabel._show()
	
func _show_victory_screen():
	if !fight_over:
		fight_over = true
		$VictoryScreen._show_screen()
		$VictoryScreen/EarningsReport._calc_earnings()
	
func _show_game_over_screen():
	if !fight_over:
		fight_over = true
		$GameOverScreen._show_screen()
		
	
