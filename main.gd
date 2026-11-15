extends Node2D

var current_tension = 0
var max_tension = 10
var starting_balance = 0

var in_shop = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test_squad = _create_test_squad()
	$Squad.squad_arr = test_squad
	$Squad._populate_squad_slots()
	$Wallet._change_value(starting_balance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _go_to_shop():
	in_shop = true
	$Fight.visible = false
	$Fight.fight_over = true
	$Fight/GameOverScreen.visible = false
	$Fight/VictoryScreen.visible = false
	$Squad._enter_shop()
	$Shop.visible = true
	$Shop._populate_shop()
	
func _start_fight():
	$Fight/EndTurn.position = Vector2(1790,1000)
	$Fight/TensionBar._update_value(0)
	$Fight.fight_over = false
	$Fight._add_enemy(_get_enemy_data("test_enemy"), _get_ai_data("test_dummy_ai"))
	$Fight.turn_number = 1
	$Fight/TurnLabel/Label.text = "Turn " + str($Fight.turn_number)
	$Fight.visible = true
	$Wallet.visible = true
	$Squad._check_squad_abilities("ROUND_START", "GAME")
	
func _show_menu():
	$Fight.visible = false
	$Fight/GameOverScreen.visible = false
	$Fight/VictoryScreen.visible = false
	$Squad.visible = false
	$Wallet.visible = false
	$TestMenu.visible = true

func _create_test_squad():
	var ally_arr = [_get_ally_data("dummy")]
	
	return ally_arr

func _get_move_data(id):
	var move = load("res://moves/" + id + ".tres")
	
	return move
	
func _get_ally_data(id):
	var ally = load("res://allies/" + id + ".tres")
	
	return ally
	
func _get_enemy_data(id):
	var enemy = load("res://enemies/" + id + ".tres")
	
	return enemy
	
func _get_ai_data(id):
	var ai = load("res://enemy_ai/" + id + ".tres")
	
	return ai
	
func _get_tension():
	return $Fight._get_tension()

func _set_tension(value):
	$Fight._set_tension(value)

func _shake():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position", Vector2(5, 8), 0.02)
	tween.tween_property(self, "position", Vector2(-5, -1), 0.03)
	tween.tween_property(self, "position", Vector2(8, -7), 0.02)
	tween.tween_property(self, "position", Vector2(-3, 2), 0.01)
	tween.tween_property(self, "position", Vector2(1, -10), 0.04)
	tween.tween_property(self, "position", Vector2(5, 8), 0.02)
	tween.tween_property(self, "position", Vector2(-5, -1), 0.03)
	tween.tween_property(self, "position", Vector2(8, -7), 0.02)
	tween.tween_property(self, "position", Vector2(-3, 2), 0.01)
	tween.tween_property(self, "position", Vector2(1, -1), 0.04)
	tween.tween_property(self, "position", Vector2.ZERO, 0.02)
