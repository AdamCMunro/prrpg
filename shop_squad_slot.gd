extends Node2D

const RAINBOW_SHADER = preload("res://shaders/effect.gdshader")

var id : String = ""
var is_empty : bool = true
var buy_value : int = 0
var mouse_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_empty:
		if mouse_over:
			z_index = 10
			$DescriptionBox.visible = true
			$MoveDescriptionBox.visible = true
			$BuyButton.visible = true


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if !is_empty:
				if buy_value <= get_parent().get_parent().wallet.balance:
					var squad_slot_arr = get_parent().get_parent().get_parent().get_node("Squad").squad_slot_arr
					for i in range(squad_slot_arr.size()):
						if squad_slot_arr[i].is_empty:
							_buy(squad_slot_arr[i], i)
							return

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true


func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	z_index = 0
	$DescriptionBox.visible = false
	$MoveDescriptionBox.visible = false
	$BuyButton.visible = false

func _buy(slot, i):
	var wallet = get_parent().get_parent().wallet
	var ally_data = wallet.get_parent()._get_ally_data(id)
	var squad = wallet.get_parent().get_node("Squad")
	
	wallet._change_value(wallet.balance - buy_value)

	squad._populate_squad_slot(slot, ally_data, i)
	
	_empty_slot()
	
func _populate_slot(new_id):
	var ally_data = get_parent().get_parent().get_parent()._get_ally_data(new_id)
	var move_data = get_parent().get_parent().get_parent()._get_move_data(ally_data.starting_move)
	
	id = new_id
	is_empty = false
	
	$EmptyRect.visible = false
	$EmptyLabel.visible = false
	
	$NameLabel.text = ally_data.name
	$HPLabel.text = str(ally_data.base_hp) + "HP"
	$ColorRect.set_color(ally_data.colour)
	
	$MoveDescriptionBox/AccLabel.text = "Acc " + str(int(move_data.base_acc * 100)) + "%"
	
	_populate_rarity(ally_data.rarity)
	_populate_descriptions(ally_data.description, ally_data.dmg_modifier, move_data.description, move_data.base_dmg_target)
	

func _populate_rarity(rarity):
	var override_material = ShaderMaterial.new()
	var str : String
	var color : String
	var pre_string : String
	var post_string : String = "[/color]"
	match rarity:
		0:
			str = "common"
			color = "666666ff"
			buy_value = 200
		1:
			str = "uncommon"
			color = "1a8066ff"
			buy_value = 300
		2:
			str = "rare"
			color = "1a66b3ff"
			buy_value = 400
		3:
			str = "epic"
			color = "1a66b3ff"
			buy_value = 600
		4:
			str = "Legendary"
			color = "ffffffff"
			override_material.shader = RAINBOW_SHADER
			buy_value = 1000
	
	pre_string = "[color=" + color + "]"
	$DescriptionBox/RarityLabel.text = pre_string + str + post_string
	$DescriptionBox/RarityLabel.set_material(override_material)
	$MoveDescriptionBox/RarityLabel.text = pre_string + str + post_string
	$MoveDescriptionBox/RarityLabel.set_material(override_material)
	$BuyButton/ValueLabel.text = "£" + str(buy_value)

func _populate_descriptions(ally_desc : String, ally_dmg : int, move_desc : String, move_dmg: int):
	var ally_label = $DescriptionBox/DescLabel
	var ally_replace_string
	
	if ally_desc.contains("{buff}"):
		ally_replace_string = ally_desc.replacen("{buff}", "Currently + 0")
		ally_label.text = ally_replace_string
	else:
		ally_label.text = ally_desc
	
	var move_label = $MoveDescriptionBox/DescLabel
	var move_replace_string
	
	if move_desc.contains("{dmg}"):
		move_replace_string = move_desc.replacen("{dmg}", str(ally_dmg + move_dmg))
		move_label.text = move_replace_string
	else:
		move_label.text = move_desc

func _empty_slot():
	is_empty = true
	$EmptyLabel.visible = true
	$EmptyRect.visible = true
	$BuyButton.visible = false
	$DescriptionBox.visible = false
	$MoveDescriptionBox.visible = false
