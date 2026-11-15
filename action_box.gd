extends Node2D

var btn_arr = []
var move_arr = []

var buttons_hidden = false
var moves_hidden = true
var info_hidden = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var child_arr = get_children()
	for i in range(1, 3):
		btn_arr.append(child_arr[i])
	
	for i in range(3, 5):
		move_arr.append(child_arr[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel_attack") and !info_hidden:
		get_parent().get_node("Target").visible = false
		_cancel_attack()
	if Input.is_action_just_pressed("cancel_attack") and !moves_hidden:
		await _hide_moves().finished
		_show_buttons()
		

func _update_colour(colour):
	$ColorRect.color = colour

func _slide_up():
	
	if !moves_hidden:
		_hide_moves()
		
	if !info_hidden:
		_hide_move_info()
	
	if buttons_hidden:
		_show_buttons()
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", 1040, 0.15)
	tween.tween_property(self, "position:y", 1050, 0.05)
	
	return tween
	
func _slide_down():
	
	if !moves_hidden:
		_hide_moves()
		
	if !info_hidden:
		_hide_move_info()
	
	var tween = get_tree().create_tween()

	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	tween.tween_property(self, "position:y", 1040, 0.05)
	tween.tween_property(self, "position:y", 1500, 0.15)
	
	return tween

func _hide_buttons():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(btn_arr[0], "position:y", -45, 0.05).as_relative()
	
	for i in range(1, btn_arr.size()):
		tween.parallel().tween_property(btn_arr[i], "position:y", -45, 0.05).as_relative()
		
	tween.tween_property(btn_arr[0], "position:y", 400, 0.1).as_relative()
		
	for i in range(1, btn_arr.size()):
		tween.parallel().tween_property(btn_arr[i], "position:y", 400, 0.1).as_relative()
	
	buttons_hidden = true
	
	return tween
	
func _show_buttons():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	for btn in btn_arr:
		btn.changing_scale = true
	
	tween.tween_property(btn_arr[0], "position:y", 45, 0.05).as_relative()
	
	for i in range(1, btn_arr.size()):
		tween.parallel().tween_property(btn_arr[i], "position:y", 45, 0.05).as_relative()
		
	tween.tween_property(btn_arr[0], "position:y", -400, 0.1).as_relative()
		
	for i in range(1, btn_arr.size()):
		tween.parallel().tween_property(btn_arr[i], "position:y", -400, 0.1).as_relative()
	
	buttons_hidden = false
	
	await tween.finished
	
	for btn in btn_arr:
		btn.changing_scale = false
	
	return tween
	
func _show_moves():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(move_arr[0], "position:y", -470, 0.1).as_relative()
	
	for m in move_arr:
		if m.move_id == get_parent().squad.selected.charge_id and get_parent().squad.selected.charge_count == 0 and !m.disabled:
			m._add_rainbow_border()
	
	for i in range(1, move_arr.size()):
		tween.parallel().tween_property(move_arr[i], "position:y", -470, 0.1).as_relative()
		
	tween.tween_property(move_arr[0], "position:y", 30, 0.08).as_relative()
	
	for i in range(1, move_arr.size()):
		tween.parallel().tween_property(move_arr[i], "position:y", 30, 0.08).as_relative()
		
	moves_hidden = false
	
	return tween
		
func _hide_moves():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(move_arr[0], "position:y", -30, 0.08).as_relative()
	
	for m in move_arr:
		m._remove_rainbow_border()
	
	for i in range(1, move_arr.size()):
		tween.parallel().tween_property(move_arr[i], "position:y", -30, 0.08).as_relative()
		
	tween.tween_property(move_arr[0], "position:y", 470, 0.1).as_relative()
	
	for i in range(1, move_arr.size()):
		tween.parallel().tween_property(move_arr[i], "position:y", 470, 0.1).as_relative()
		
	moves_hidden = true
	
	return tween
	
func _update_moves(arr):
	for i in range(arr.size()):
		var move = get_parent().get_parent()._get_move_data(arr[i])
		move_arr[i].move_id = move.id
		move_arr[i].get_node("Label").text = move.name
	
	if arr.size() < 2:
		move_arr[1]._disable()
		

func _show_move_info(id):
	var move = get_parent().get_parent()._get_move_data(id)
	
	$MoveInfoBox/NameLabel.text = move.name
	var replacement_string = ""
	var text_mod_open = "[color=red][outline_color=white][outline_size=5]"
	var text_mod_close = "[/outline_size][/outline_color][/color]"
	if get_parent().squad.selected.dmg_mod != 0:
		replacement_string = text_mod_open + str(move.base_dmg_target + get_parent().squad.selected.dmg_mod) + text_mod_close
	else:
			replacement_string = str(move.base_dmg_target)
	var desc = move.description.replacen("{dmg}", replacement_string)
	$MoveInfoBox/DescLabel.text = desc
	$MoveInfoBox/AccLabel.text = "Accuracy: " + str(int((min(move.base_acc + get_parent().squad.selected.acc_mod, 1)) * 100)) + "%"
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($MoveInfoBox, "position:y", -520, 0.1).as_relative()
		
	tween.tween_property($MoveInfoBox, "position:y", 30, 0.08).as_relative() 
		
	info_hidden = false
	
	var target_arc = get_parent().get_node("TargetArc")
	target_arc.get_node("Path2D/Line2D").default_color = $ColorRect.color
	target_arc.visible = true
	
	var target = get_parent().get_node("Target")
	target.move = move
	target.user = get_parent().get_parent().get_node("Squad").selected
	target._change_colour($ColorRect.color)
	
	
	return tween

func _hide_move_info():
	var tween = get_tree().create_tween()
	
	var target_arc = get_parent().get_node("TargetArc")
	target_arc.visible = false
	
	var target = get_parent().get_node("Target")
	target.visible = false
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property($MoveInfoBox, "position:y", -30, 0.08).as_relative()
		
	tween.tween_property($MoveInfoBox, "position:y", 520, 0.1).as_relative() 
		
	info_hidden = true
	
	return tween
	
func _cancel_attack():
	get_parent().get_node("TargetArc").visible = false
	await _hide_move_info().finished
	_show_moves()
		
