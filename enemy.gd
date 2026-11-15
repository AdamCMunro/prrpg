extends Node2D

var mouse_over = false
var is_defending = false

@onready var main = get_parent().get_parent()
@onready var fight = get_parent()
@onready var target = get_parent().get_node("Target")
@onready var action_box = get_parent().get_node("ActionBox")

var enemy_data
var ai_data

var id

var max_hp
var current_hp

var dmg_mod = 0
var acc_mod = 0

var move_arr

var buff_arr = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_over and !action_box.info_hidden:
		target._change_target_type("ENEMY")
		target.attack_target = self
		target.position = position
		target.visible = true


func _on_area_2d_mouse_entered() -> void:
	mouse_over = true


func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	if target.visible:
		target.visible = false
		
func _populate_enemy_data():
	max_hp = enemy_data.base_hp
	current_hp = max_hp
	id = enemy_data.id
	
	$HealthBar/ProgressBar.max_value = max_hp
	$HealthBar/ProgressBar.value = max_hp
	
	$HealthBar/Label.text = str(max_hp) + "/" + str(max_hp)
	
	move_arr = [enemy_data.move_1, enemy_data.move_2]

func _add_buff(new_buff):
	pass

func _take_damage(damage):
	_animate_damage()
	main.get_node("Squad")._check_squad_abilities("DAMAGED", "ENEMY")
	main.get_node("Squad")._check_squad_abilities("HEALTH_BELOW", "ENEMY")
	fight._show_damage(position, damage)
	if current_hp - damage <= 0:
		current_hp = 0
		$HealthBar._update_value(current_hp)
		_die()
	else:
		current_hp -= damage
		$HealthBar._update_value(current_hp)

func _recieve_heal(heal):
	main.get_node("Squad")._check_squad_abilities("HEALED", "ENEMY")
	main.get_node("Squad")._check_squad_abilities("HEALTH_ABOVE", "ENEMY")
	fight._show_heal(position, heal)
	if current_hp + heal > max_hp:
		current_hp = max_hp
		$HealthBar._update_value(current_hp)
	else:
		current_hp += max_hp
		$HealthBar._update_value(current_hp)

func _miss():
	main.get_node("Squad")._check_squad_abilities("MISSED", "ENEMY")
	fight._show_miss(position)

func _animate_damage():
	var tween = get_tree().create_tween()
	
	main._shake()
	
	tween.tween_property($Area2D, "position:x", 10, 0.05).as_relative()
	tween.tween_property($Area2D, "position:x", -30, 0.05).as_relative()
	tween.tween_property($Area2D, "position:x", 40, 0.05).as_relative()
	tween.tween_property($Area2D, "position:x", -30, 0.05).as_relative()
	tween.tween_property($Area2D, "position:x", 15, 0.05).as_relative()
	tween.tween_property($Area2D, "position:x", -5, 0.05).as_relative()
	
	$Area2D/Flash.visible = true
	await get_tree().create_timer(0.05).timeout
	$Area2D/Flash.visible = false
	await get_tree().create_timer(0.05).timeout
	$Area2D/Flash.visible = true
	await get_tree().create_timer(0.05).timeout
	$Area2D/Flash.visible = false
	await get_tree().create_timer(0.05).timeout
	$Area2D/Flash.visible = true
	await get_tree().create_timer(0.05).timeout
	$Area2D/Flash.visible = false
	await get_tree().create_timer(0.05).timeout
	
func _die():
	main.get_node("Squad")._check_squad_abilities("KILLED", "ENEMY")
	fight.squad._end_turn()
	fight.get_node("EndTurn")._slide_out()
	await _animate_death().finished
	await get_tree().create_timer(0.5).timeout
	fight._show_victory_screen()
	queue_free()

	
func _take_turn():
	ai_data._take_action(self, fight.squad.squad_slot_arr)
	await get_tree().create_timer(2).timeout
	if !fight.fight_over:
		fight._start_ally_turn()

func _show_enemy_action_box(move, tgt):
	$EnemyActionBox/Label.text = enemy_data.name + " used " + move.name + " on " + tgt.ally_name + "!"
	await $EnemyActionBox._slide_up().finished
	await get_tree().create_timer(1.5).timeout
	await $EnemyActionBox._slide_down().finished
	
func _animate_death():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", -20, 0.3).as_relative()
	tween.tween_property(self, "position:y", 0, 0.1).as_relative()
	tween.tween_property(self, "position:y", 1000, 0.35).as_relative()
	
	return tween
