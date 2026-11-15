extends Node2D

const SHINE_SHADER = preload("res://shaders/shine.gdshader")
const WINDOW_HEIGHT = 1080

var is_empty = true
var is_down = false
var is_selected = false
var is_defending = false
var is_charging = false
var turn_ended = false

var charge_count = 0
var charge_id = ""

var index

@onready var main = get_parent().get_parent()
@onready var fight = main.get_node("Fight")
@onready var action_box = fight.get_node("ActionBox")
@onready var target = fight.get_node("Target")

var id = ""
var ally_name = ""
var base_max_hp = 0
var max_hp = 0
var current_hp = 0
var move_arr = []
var base_dmg_mod = 0
var dmg_mod = 0
var base_acc_mod = 0
var acc_mod = 0.0
var desc = ""
var ability = null
var buff_arr = []
var sell_value = 0

var mouse_over = false
var changing_scale = false
var mouse_over_scale = Vector2(1.1,1.1)
var normal_scale = Vector2(1,1)
var unselected_scale = Vector2(0.95,0.95)
var selected_scale = Vector2(1.35,1.35)

var scale_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !changing_scale and !is_selected and action_box.info_hidden and !turn_ended and (!fight.fight_over or get_parent().in_shop):
		if mouse_over and scale != mouse_over_scale:
			z_index = 10
			changing_scale = true
			await _animate_scale_change(scale, mouse_over_scale).finished
			changing_scale = false
		elif !mouse_over and scale != normal_scale and scale != unselected_scale:
			changing_scale = true
			if get_parent().selected:
				await _animate_scale_change(scale, unselected_scale).finished
			else:
				await _animate_scale_change(scale, normal_scale).finished
			changing_scale = false
			z_index = 0
	elif !action_box.info_hidden:
		if mouse_over:
			z_index = 0
			target.position = position 
			if is_selected:
				target._change_target_type("SELF")
				target.attack_target = self
			else:
				target._change_target_type("ALLY")
				target.attack_target = self
			target.visible = true
	
	if !is_selected and action_box.info_hidden and !fight.fight_over:
		if mouse_over:
			z_index = 10
			$DescriptionBox.visible = true
	elif get_parent().in_shop:
		if mouse_over and !is_empty:
			z_index = 10
			$DescriptionBox.visible = true
			$SellButton.visible = true
	elif action_box.info_hidden and !fight.fight_over and !changing_scale:
		if mouse_over:
			z_index = 10
			$SelectedDescriptionBox.visible = true
			
		

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	$DescriptionBox.visible = false
	$SelectedDescriptionBox.visible = false
	$SellButton.visible = false
	$SellButton/ValueLabel.text = "£" + str(sell_value)
	z_index = 0
	if !action_box.info_hidden:
		target.visible = false

func _animate_scale_change(current_scale, new_scale):
	
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
		
	scale_tween = get_tree().create_tween()
	
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	
	if current_scale > new_scale:
		scale_tween.tween_property(self, "scale", current_scale * 1.1, 0.05)
		scale_tween.tween_property(self, "scale", new_scale * 0.95, 0.1)
		scale_tween.tween_property(self, "scale", new_scale, 0.05)
	else:
		scale_tween.tween_property(self, "scale", current_scale * 0.95, 0.05)
		scale_tween.tween_property(self, "scale", new_scale * 1.1, 0.1)
		scale_tween.tween_property(self, "scale", new_scale, 0.05)
	
	return scale_tween
	
func _shine():
	var override_material = ShaderMaterial.new()
	override_material.shader = SHINE_SHADER
	$ColorRect.set_material(override_material)
	
func _remove_shine():
	var override_material = ShaderMaterial.new()
	$ColorRect.set_material(override_material)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if !is_selected and action_box.info_hidden and !turn_ended and !get_parent().in_shop:
				_select()
			if get_parent().in_shop:
				if $SellButton/ValueLabel.text != "sell?":
					$SellButton/ValueLabel.text = "sell?"
				else:
					_sell()
				
func _sell():
	var wallet = get_parent().get_parent().get_node("Wallet")
	
	wallet._change_value(wallet.balance + sell_value)
	
	_empty_squad_slot()
	
			
func _select():
	changing_scale = true
	z_index = 10
	if get_parent().selected != null:
		_hide_bond_bar()
	await _animate_scale_change(scale, normal_scale).finished
	get_parent()._select_squad_member(self)
	is_selected = true
	_shine()
	await get_tree().create_timer(0.5).timeout
	changing_scale = false

func _animate_selection():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	_animate_scale_change(scale, selected_scale)
	
	tween.tween_property(self, "position:y", -30, 0.1).as_relative()
	tween.tween_property(self, "position:y", WINDOW_HEIGHT - 100, 0.15)
	tween.parallel().tween_property(self, "position:x", 20, 0.1).as_relative()
	tween.tween_property(self, "position:y", WINDOW_HEIGHT - 145, 0.1)
	
func _animate_nudge(start, end):
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", start * 1.1, 0.05)
	tween.tween_property(self, "position:y", end * 0.9, 0.1)
	tween.tween_property(self, "position:y", end, 0.05)
	
	changing_scale = false
	
func _show_bond_bar():
	var tween = get_tree().create_tween()
	
	var selected_colour = get_parent().selected.get_node("ColorRect").color
	
	$BondBar/ProgressBar.get("theme_override_styles/fill").bg_color = selected_colour
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($BondBar, "position:x", 130, 0.08)
	tween.tween_property($BondBar, "position:x", 120, 0.05)
	
func _hide_bond_bar():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($BondBar, "position:x", 130, 0.05)
	tween.tween_property($BondBar, "position:x", 0, 0.08)
	
func _change_bond_bar(val):
	$BondBar._update_value(val)

func _add_buff(new_buff):
	buff_arr.append(new_buff)
	_update_desc()

func _update_desc():
	var label = $DescriptionBox/DescLabel
	var selected_label = $SelectedDescriptionBox/DescLabel
	var pre_string = " Currently [color=red][outline_color=white][outline_size=5]"
	var post_string = "[/outline_size][/outline_color][/color]"
	var val_string
	var replace_string
	var value = 0.0
	var enemy = get_parent().enemy
	var squad_slot_arr = get_parent().squad_slot_arr
	
	if !desc.contains("{buff}"):
		return false
	
	for slot in squad_slot_arr:
		for buff in slot.buff_arr:
			if buff.source == id:
				value += buff.value
	
	if int(value) == value:
		value = int(value)
		val_string = str(value)
	else:
		value = value * 100
		val_string = str(value) + "%"
		
	
	if value > 0:
		replace_string = desc.replacen("{buff}", pre_string + "+" + val_string + post_string)
	elif value < 0:
		replace_string = desc.replacen("{buff}", pre_string +  val_string + post_string)
	else:
		replace_string = desc.replacen("{buff}", "Currently +" +  val_string)
	
	label.text = replace_string
	selected_label.text = replace_string
		
func _take_damage(damage):
	_check_ability("DAMAGED", "SELF")
	_check_ability("HEALTH_BELOW", "SELF")
	_animate_damage()
	fight._show_damage(position, damage)
	if is_defending:
		fight._show_defending(Vector2(position.x - 20, position.y))
	main._set_tension(main._get_tension() + 1)
	if current_hp - damage <= 0:
		current_hp = 0
		_update_hp_label()
		_down()
	else:
		current_hp -= damage
		_update_hp_label()

func _recieve_heal(heal):
	if is_down:
		is_down = false
		_check_status_label()
	_check_ability("HEALED", "SELF")
	_check_ability("HEALTH_ABOVE", "SELF")
	_animate_heal()
	fight._show_heal(position, heal)
	if current_hp + heal > max_hp:
		current_hp = max_hp
		_update_hp_label()
	else:
		current_hp += heal
		_update_hp_label()

func _miss():
	_check_ability("MISSED", "SELF")
	fight._show_miss(position)

func _animate_damage():
	var tween = get_tree().create_tween()
	
	main._shake()
	
	tween.tween_property(self, "position:x", 5, 0.05).as_relative()
	tween.tween_property(self, "position:x", -15, 0.05).as_relative()
	tween.tween_property(self, "position:x", 20, 0.05).as_relative()
	tween.tween_property(self, "position:x", -15, 0.05).as_relative()
	tween.tween_property(self, "position:x", 7.5, 0.05).as_relative()
	tween.tween_property(self, "position:x", -2.5, 0.05).as_relative()
	tween.tween_property(self, "position:x", 110, 0.05)
	
	$DmgRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$DmgRect.visible = false
	await get_tree().create_timer(0.05).timeout
	$DmgRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$DmgRect.visible = false
	await get_tree().create_timer(0.05).timeout
	$DmgRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$DmgRect.visible = false
	await get_tree().create_timer(0.05).timeout

func _animate_heal():
	$HealRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$HealRect.visible = false
	await get_tree().create_timer(0.05).timeout
	$HealRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$HealRect.visible = false
	await get_tree().create_timer(0.05).timeout
	$HealRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$HealRect.visible = false
	await get_tree().create_timer(0.05).timeout

func _animate_charge():
	$ChargeRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$ChargeRect.visible = false
	await get_tree().create_timer(0.05).timeout
	$ChargeRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$ChargeRect.visible = false
	await get_tree().create_timer(0.05).timeout
	$ChargeRect.visible = true
	await get_tree().create_timer(0.05).timeout
	$ChargeRect.visible = false
	await get_tree().create_timer(0.05).timeout

func _update_hp_label():
	if max_hp > 9 and current_hp < 10:
		$HPLabel.text = "0" + str(current_hp) + "/" + str(max_hp) + "hp"
	else:
		$HPLabel.text = str(current_hp) + "/" + str(max_hp) + "hp"

func _end_turn():
	
	turn_ended = true
	
	if !is_empty:
		if is_charging and charge_count == 0:
			is_charging = false
		get_parent()._check_turn_end()
		await get_tree().create_timer(0.3).timeout
		_check_status_label()
		$StatusRect.visible = true
		$StatusLabel.visible = true

func _defend():
	is_defending = true
	_check_ability("DEFEND", "SELF")
	_end_turn()

func _check_status_label():
	if is_empty:
		return false
	elif is_down:
		$StatusLabel.text = "down"
		$StatusLabel.add_theme_color_override("font_color", Color(0.6,0,0))
	elif is_defending:
		$StatusLabel.text = "dfnd"
		$StatusLabel.add_theme_color_override("font_color", Color(1,1,1))
	elif is_charging:
		$StatusLabel.text = "chrg\n(" + str(charge_count) + ")"
		$StatusLabel.add_theme_color_override("font_color", Color(1,1,1))
	else:
		$StatusLabel.text = "turn\nended"
		$StatusLabel.add_theme_color_override("font_color", Color(1,1,1))

func _down():
	is_down = true
	_check_ability("KILLED", "SELF")
	_end_turn()
	get_parent()._check_squad_down()

func _check_ability(trigger_type, trigger_target):
	match trigger_target:
		"SELF":
			if ability != null:
				if ability._condition_met(trigger_type, "SELF", self, get_parent().squad_slot_arr, get_parent().enemy):
					_add_ability_used_effect()
				get_parent()._check_squad_abilities(trigger_type, "ALLY", self)
		"ALLY":
			get_parent()._check_squad_abilities(trigger_type, "ALLY")
		"ENEMY":
			get_parent()._check_squad_abilities(trigger_type, "ENEMY")
			
func _add_ability_used_effect():
	var status_shown = false
	
	if $StatusRect.visible:
		status_shown = true
		$StatusRect.visible = false
		$StatusLabel.visible = false
	
	$EffectRect.visible = true
	await get_tree().create_timer(0.15).timeout
	$EffectRect.visible = false
	$FlashRect.visible = true
	await get_tree().create_timer(0.1).timeout
	$EffectRect.visible = true
	$FlashRect.visible = false
	await get_tree().create_timer(0.15).timeout
	
	$EffectRect.visible = false
	$FlashRect.visible = true
	await get_tree().create_timer(0.1).timeout
	$FlashRect.visible = false
	
	if status_shown:
		$StatusRect.visible = true
		$StatusLabel.visible = true
	
func _return_to_start_pos(i):
	changing_scale = true
	_animate_scale_change(scale, normal_scale)
	
	var total_distance = 15 * i
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position", Vector2(-10,-10), 0.05).as_relative()
	tween.tween_property(self, "position", Vector2(40, total_distance + 30), 0.1).as_relative()
	tween.tween_property(self, "position", Vector2(-10,-5), 0.05).as_relative()
	
	await tween.finished
	
	changing_scale = false

func _empty_squad_slot():
	is_empty = true
	is_down = false
	is_selected = false
	is_defending = false
	is_charging = false
	turn_ended = false
	
	for i in range(0, 3):
		var other_index = get_parent().squad_slot_arr[i].index
		var ally_removal_arr = []
		get_parent()._update_bond(index, other_index, 0)
		for buff in get_parent().squad_slot_arr[i].buff_arr:
			if buff.source != id:
				ally_removal_arr.append(buff)
		get_parent().squad_slot_arr[i].buff_arr = ally_removal_arr
	
	id = ""
	ally_name = ""
	base_max_hp = 0
	max_hp = 0
	current_hp = 0
	move_arr = []
	base_dmg_mod = 0
	dmg_mod = 0
	base_acc_mod = 0
	acc_mod = 0.0
	desc = ""
	ability = null
	
	var removal_arr = []
	
	for i in range(buff_arr.size()):
		if buff_arr[i].transferable:
			removal_arr.append(buff_arr[i])
	
	buff_arr = removal_arr
	
	mouse_over = false
	$SellButton.visible = false
	$DescriptionBox.visible = false
	
	$MoveStuff/MoveBox.is_empty = true
	$MoveStuff/MoveBox/EmptyRect.visible = true
	$MoveStuff/MoveBox/EmptyLabel.visible = true
	
	$MoveStuff/MoveBox2.is_empty = true
	$MoveStuff/MoveBox2/EmptyRect.visible = true
	$MoveStuff/MoveBox2/EmptyLabel.visible = true
	
	$EmptyLabel.visible = true
	$EmptyRect.visible = true
	
	for i in range(0, 3):
		var other_index = get_parent().squad_slot_arr[i].index
		get_parent()._update_bond(index, other_index, 0)
		for buff in get_parent().squad_slot_arr[i].buff_arr:
			if buff.source == id:
				buff.remove()
	
