extends Node2D

const RAINBOW_SHADER = preload("res://shaders/effect.gdshader")

enum Rarity
{
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var squad_arr
@onready var squad_slot_arr = get_children()
@onready var fight = get_parent().get_node("Fight")
@onready var action_box = get_parent().get_node("Fight/ActionBox")
@onready var enemy = get_parent().get_node("Fight/Enemy")
var selected = null

var stowed = false
var in_shop = false

var bond_dict = {"01":0, "02":0, "12":0,}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _wipe_squad():
	for i in range(squad_slot_arr.size()):
		squad_slot_arr[i].is_defending = false
		squad_slot_arr[i].is_down = false
		squad_slot_arr[i].is_charging = false
		squad_slot_arr[i].charge_count = 0
		squad_slot_arr[i].charge_id = ""
		squad_slot_arr[i].buff_arr = []
		squad_slot_arr[i].turn_ended = false
		squad_slot_arr[i].is_selected = false
		squad_slot_arr[i].get_node("StatusRect").visible = false
		squad_slot_arr[i].get_node("StatusLabel").visible = false
		squad_slot_arr[i].position = Vector2(130,120 + (210 * i))
		squad_slot_arr[i].scale = Vector2(1,1)
		_populate_squad_slots()
	bond_dict["01"] = 0
	bond_dict["02"] = 0
	bond_dict["12"] = 0
		

func _populate_squad_slots():
	for i in range(squad_arr.size()):
		_populate_squad_slot(squad_slot_arr[i], squad_arr[i], i)

func _populate_squad_slot(slot, ally, i):
		var rectangle = slot.get_node("ColorRect")
		rectangle.set_color(ally.colour)
		var name_label = slot.get_node("NameLabel")
		name_label.text = ally.name
		var desc_rectangle = slot.get_node("DescriptionBox/BorderRect")
		desc_rectangle.set_color(ally.colour)
		var desc_label = slot.get_node("DescriptionBox/DescLabel")
		desc_label.text = ally.description
		var selected_desc_rectangle = slot.get_node("SelectedDescriptionBox/BorderRect")
		selected_desc_rectangle.set_color(ally.colour)
		var selected_desc_label = slot.get_node("SelectedDescriptionBox/DescLabel")
		selected_desc_label.text = ally.description
		slot.desc = ally.description
		slot._update_desc()
		_populate_rarity(ally.rarity, squad_slot_arr[i])
		var hp_label = slot.get_node("HPLabel")
		hp_label.text = str(ally.base_hp) + "/" + str(ally.base_hp) + "hp"
		slot.is_empty = false
		slot.get_node("EmptyRect").visible = false
		slot.get_node("EmptyLabel").visible = false
		slot.index = i
		slot.id = ally.id
		slot.ally_name = ally.name
		slot.base_max_hp = ally.base_hp
		slot.max_hp = ally.base_hp
		slot.current_hp = ally.base_hp
		slot.move_arr = [ally.starting_move]
		slot.get_node("MoveStuff/MoveBox/Label").text = get_parent()._get_move_data(ally.starting_move).name
		slot.get_node("MoveStuff/MoveBox/ColorRect").set_color(ally.colour)
		slot.get_node("MoveStuff/MoveBox/EmptyRect").visible = false
		slot.get_node("MoveStuff/MoveBox/EmptyLabel").visible = false
		slot.get_node("MoveStuff/MoveBox").is_empty = false
		slot.get_node("MoveStuff/MoveBox").id = ally.starting_move
		slot.get_node("MoveStuff/MoveBox2/ColorRect").set_color(ally.colour)
		slot.base_dmg_mod = ally.dmg_modifier
		slot.dmg_mod = ally.dmg_modifier
		slot.base_acc_mod = ally.acc_modifier
		slot.acc_mod = ally.acc_modifier
		slot.ability = ally.ability

func _populate_rarity(rarity : Rarity, slot):
	var override_material = ShaderMaterial.new()
	var str : String
	var color : String
	var pre_string : String
	var post_string : String = "[/color]"
	match rarity:
		Rarity.COMMON:
			str = "common"
			color = "666666ff"
			slot.sell_value = 100
		Rarity.UNCOMMON:
			str = "uncommon"
			color = "1a8066ff"
			slot.sell_value = 150
		Rarity.RARE:
			str = "rare"
			color = "1a66b3ff"
			slot.sell_value = 200
		Rarity.EPIC:
			str = "epic"
			color = "1a66b3ff"
			slot.sell_value = 300
		Rarity.LEGENDARY:
			str = "Legendary"
			color = "ffffffff"
			override_material.shader = RAINBOW_SHADER
			slot.sell_value = 500
	
	pre_string = "[color=" + color + "]"
	slot.get_node("DescriptionBox/RarityLabel").text = pre_string + str + post_string
	slot.get_node("DescriptionBox/RarityLabel").set_material(override_material)
	slot.get_node("SelectedDescriptionBox/RarityLabel").text = pre_string + str + post_string
	slot.get_node("SelectedDescriptionBox/RarityLabel").set_material(override_material)
	slot.get_node("SellButton/ValueLabel").text = "£" + str(slot.sell_value)
			
		

func _select_squad_member(selected_slot):
	if selected != null:
		_swap_squad_member(selected_slot)
		return
	
	selected = selected_slot
	selected_slot._animate_selection()
	action_box._update_moves(selected_slot.move_arr)
	action_box._update_colour(selected_slot.get_node("ColorRect").color)
	action_box._slide_up()
	
	_stow_squad_slots(selected_slot)
	_nudge_squad_slots(selected_slot)
	_show_bond_bars(selected_slot)
			
func _swap_squad_member(selected_slot):
	_swap_index(selected, selected_slot)
	_hide_bond_bars()
	_return_to_slot(selected, selected_slot.position, selected_slot.unselected_scale)
	selected = selected_slot
	await get_tree().create_timer(0.25).timeout
	_show_bond_bars(selected_slot)
	selected_slot.z_index = 10
	selected_slot._animate_selection()
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(selected_slot, "position:x", 20, 0.05).as_relative()
	
	await action_box._slide_down().finished
	action_box._update_moves(selected_slot.move_arr)
	action_box._update_colour(selected_slot.get_node("ColorRect").color)
	action_box._slide_up()

func _swap_index(a,b):
	var a_index
	var b_index
	
	for i in range(squad_slot_arr.size()):
		if squad_slot_arr[i] == a:
			a_index = i
		elif squad_slot_arr[i] == b:
			b_index = i
	
	squad_slot_arr[a_index] = b
	squad_slot_arr[b_index] = a

func _reorder_arr(selected_slot):
	squad_slot_arr.erase(selected_slot)
	squad_slot_arr.append(selected_slot)

	
func _return_to_slot(slot, pos, scle):
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(slot, "position:x", pos.x - 5, 0.05)
	tween.parallel().tween_property(slot, "position:y", pos.y - 5, 0.05)
	tween.parallel().tween_property(slot, "scale", scle * 0.95, 0.05)
	tween.tween_property(slot, "position:x", pos.x, 0.05)
	tween.parallel().tween_property(slot, "position:y", pos.y, 0.05)
	tween.parallel().tween_property(slot, "scale", scle, 0.05)
	
	_normalise_slot(slot)
	
func _normalise_slot(slot):
	slot.is_selected = false
	slot.changing_scale = false
	slot._remove_shine()
	slot.z_index = 0

func _stow_squad_slots(selected_slot):
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	for slot in squad_slot_arr:
		if slot != selected_slot:
			slot.changing_scale = true
			slot._animate_scale_change(slot.scale, slot.unselected_scale)
	
	for slot in squad_slot_arr:
		if slot != selected_slot:
			tween.parallel().tween_property(slot, "position:x", 10, 0.05).as_relative()
			tween.parallel().tween_property(slot, "position:x", -20, 0.1).as_relative()
			tween.parallel().tween_property(slot, "position:x", -15, 0.05).as_relative()

func _stow_selected_slot():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	selected.changing_scale = true
	selected._animate_scale_change(selected.scale, selected.unselected_scale)
	
	tween.tween_property(selected, "position:x", 10, 0.05).as_relative()
	tween.tween_property(selected, "position:x", -40, 0.1).as_relative()
	tween.tween_property(selected, "position:x", -10, 0.05).as_relative()
	
	tween.tween_property(selected, "position:y", 20, 0.05).as_relative()
	tween.tween_property(selected, "position:y", -470, 0.1).as_relative()
	tween.tween_property(selected, "position:y", 10, 0.05).as_relative()
	
			
func _get_bond(a1, a2):
	if bond_dict.has(str(a1) + str(a2)):
		return bond_dict[str(a1) + str(a2)]
	elif bond_dict.has(str(a2) + str(a1)):
		return bond_dict[str(a2) + str(a1)]
	else:
		return -1
		
func _update_bond(a1, a2, value):
	if bond_dict.has(str(a1) + str(a2)):
		bond_dict[str(a1) + str(a2)] = value
	elif bond_dict.has(str(a2) + str(a1)):
		bond_dict[str(a2) + str(a1)] = value
	else:
		return -1

func _show_bond_bars(selected_slot):
	for slot in squad_slot_arr:
		if slot != selected_slot and !slot.is_empty:
			slot._change_bond_bar(_get_bond(slot.index, selected_slot.index))
			slot._show_bond_bar()
			
func _hide_bond_bars():
	for slot in squad_slot_arr:
		if !slot.is_empty:
			slot._hide_bond_bar()
			
func _nudge_squad_slots(selected_slot):
	var nudge_distance = 15
	var extra_nudge = 0
	var count = 0
	for slot in squad_slot_arr:
		count += 1
		if slot == selected_slot:
			extra_nudge = 195
			continue
		if slot != selected_slot:
			slot._animate_nudge(slot.position.y, slot.position.y - (nudge_distance * count) - extra_nudge)
			
func _check_turn_end():
	if fight.enemy_turn:
		return false
		
	for slot in squad_slot_arr:
		if !slot.turn_ended and !slot.is_empty:
			slot._select()
			return false
	
	if selected != null:
		_reorder_arr(selected)
		_hide_bond_bars()
		_normalise_slot(selected)
		_stow_selected_slot()
		action_box._slide_down()
		selected = null
		stowed = true
	
	fight.get_node("EndTurn")._shine()

func _end_turn():
	for slot in squad_slot_arr:
		if slot.charge_count == 0:
			slot.is_charging = false
			slot.charge_id = ""
		slot.turn_ended = true
		slot._check_status_label()
		slot.get_node("StatusRect").visible = true
		slot.get_node("StatusLabel").visible = true
			
		
	if selected != null:
		_reorder_arr(selected)
		_hide_bond_bars()
		_normalise_slot(selected)
		_stow_selected_slot()
		action_box._slide_down()
		selected = null
	elif !stowed:
		_stow_squad_slots(selected)
		_nudge_squad_slots(selected)
	
func _start_turn():
	stowed = false
	
	for i in range(squad_slot_arr.size()):
		if !squad_slot_arr[i].is_empty:
		
			if squad_slot_arr[i].is_charging:
				squad_slot_arr[i].turn_ended = true
				squad_slot_arr[i].charge_count -= 1
				if squad_slot_arr[i].charge_count > 0:
					squad_slot_arr[i]._check_status_label()
					squad_slot_arr[i].get_node("StatusRect").visible = true
					squad_slot_arr[i].get_node("StatusLabel").visible = true
					squad_slot_arr[i].is_defending = false
					squad_slot_arr[i]._return_to_start_pos(i)
					continue
				else:
					squad_slot_arr[i]._animate_charge()
			
			if !squad_slot_arr[i].is_down:
				squad_slot_arr[i].get_node("StatusRect").visible = false
				squad_slot_arr[i].get_node("StatusLabel").visible = false
				squad_slot_arr[i].turn_ended = false
			squad_slot_arr[i].is_defending = false
		squad_slot_arr[i]._return_to_start_pos(i)
		
func _check_squad_abilities(con, con_tgt_type, sender = null):
	for slot in squad_slot_arr:
		if slot != sender and slot.ability != null:
			if slot.ability._condition_met(con, con_tgt_type, slot, squad_slot_arr, enemy, fight.get_node("TensionBar")):
				slot._add_ability_used_effect()

func _check_squad_down():
	for slot in squad_slot_arr:
		if !slot.is_empty and !slot.is_down:
			return false
	
	_check_turn_end()
	get_parent().get_node("Fight/EndTurn")._slide_out()
	get_parent().get_node("Fight")._show_game_over_screen()

func _enter_shop():
	in_shop = true
	for i in range(squad_slot_arr.size()):
		squad_slot_arr[i]._return_to_start_pos(i)
		squad_slot_arr[i].turn_ended = false
		squad_slot_arr[i].get_node("MoveStuff").visible = true
		if !squad_slot_arr[i].is_down:
			squad_slot_arr[i].get_node("StatusLabel").visible = false
			squad_slot_arr[i].get_node("StatusRect").visible = false
	
			
