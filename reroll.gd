extends Node2D

@onready var wallet = get_parent().get_parent().get_node("Wallet")

var ally_dict :Dictionary[String, int] = {}
var ally_weights_total :int = 0

var move_dict :Dictionary[String, int] = {}
var move_weights_total :int = 0

var mouse_over = false

var cost = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_get_ally_dict()
	_get_move_dict()
	_roll()
	$BuyLabel.text = "£" + str(cost)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_over:
		$BuyLabel.visible = true
		$BuyRect.visible = true
		$Label.visible = false

func _get_move_dict():
	var temp_arr = ResourceLoader.list_directory("res://shop_moves")
	
	for t in temp_arr:
		var id = t.get_slice(".", 0)
		var rarity = get_parent().get_parent()._get_move_data(id).rarity
		var weight = _get_weight(rarity)
		move_dict[id] = weight
		move_weights_total += weight
	
	return true

func _get_ally_dict():
	var temp_arr = ResourceLoader.list_directory("res://shop_allies")
	
	for t in temp_arr:
		var id = t.get_slice(".", 0)
		var rarity = get_parent().get_parent()._get_ally_data(id).rarity
		var weight = _get_weight(rarity)
		ally_dict[id] = weight
		ally_weights_total += weight
	
	return true

func _get_weight(rarity):
	match rarity:
			0:
				return 10
			1:
				return 7
			2:
				return 5
			3:
				return 3
			4:
				return 1

func _roll():
	var ally_arr = get_parent().ally_stock_arr
	var move_arr = get_parent().move_stock_arr
	var dupe_checked = false
	var dupe_found = false
	var squad_slot_arr = get_parent().get_parent().get_node("Squad").squad_slot_arr
	
	for i in range(3):
		dupe_checked = false
		var new_ally
		while !dupe_checked:
			dupe_found = false
			new_ally = _roll_allies()
			if ally_arr.has(new_ally):
				dupe_found = true
			for slot in squad_slot_arr:
				if slot.id == new_ally:
					dupe_found = true
			if !dupe_found:
				dupe_checked = true
		
		ally_arr.append(new_ally)
		move_arr.append(_roll_moves())
		
	
func _roll_allies():
	
	var rng = RandomNumberGenerator.new()
	var weight = rng.randi_range(1, ally_weights_total)
	
	for ally in ally_dict:
		weight -= ally_dict[ally]
		if weight <= 0:
			return ally
	
	return false
	
func _roll_moves():
	var rng = RandomNumberGenerator.new()
	var weight = rng.randi_range(1, move_weights_total)
	
	for move in move_dict:
		weight -= move_dict[move]
		if weight <= 0:
			return move
	
	return false
		

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true


func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	$BuyLabel.visible = false
	$BuyRect.visible = false
	$Label.visible = true


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if cost <= wallet.balance:
				get_parent()._populate_shop()
				wallet._change_value(wallet.balance - cost)
				cost = cost * 1.5
				$BuyLabel.text = "£" + str(cost)
