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
			$DescriptionBox.visible = true
			$NameLabel.visible = false
			$BuyButton.visible = true

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			if !is_empty:
				if buy_value <= get_parent().get_parent().wallet.balance:
							_buy()

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	z_index = 10


func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	z_index = 0
	$DescriptionBox.visible = false
	$BuyButton.visible = false
	$NameLabel.visible = true

func _buy():
	var wallet = get_parent().get_parent().wallet
	var ally_data = wallet.get_parent()._get_ally_data(id)
	var squad = wallet.get_parent().get_node("Squad")
	
	wallet._change_value(wallet.balance - buy_value)
	
	#something something add to squad slot
	
	_empty_slot()
	
func _populate_slot(new_id):
	var move_data = get_parent().get_parent().get_parent()._get_move_data(new_id)
	
	id = new_id
	is_empty = false
	
	$EmptyRect.visible = false
	$EmptyLabel.visible = false
	
	$NameLabel.text = move_data.name
	_populate_rarity(move_data.rarity)
	_populate_description(move_data.description, move_data.base_dmg_target, move_data.base_acc)
	

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
			buy_value = 100
		1:
			str = "uncommon"
			color = "1a8066ff"
			buy_value = 150
		2:
			str = "rare"
			color = "1a66b3ff"
			buy_value = 200
		3:
			str = "epic"
			color = "1a66b3ff"
			buy_value = 300
		4:
			str = "Legendary"
			color = "ffffffff"
			override_material.shader = RAINBOW_SHADER
			buy_value = 500
	
	pre_string = "[color=" + color + "]"
	
	$DescriptionBox/BorderRect.set_color(color)
	$DescriptionBox/BorderRect.set_material(override_material)
	
	$ColorRect.set_color(color)
	$ColorRect.set_material(override_material)
	
	$DescriptionBox/RarityLabel.text = pre_string + str + post_string
	$DescriptionBox/RarityLabel.set_material(override_material)
	$BuyButton/ValueLabel.text = "£" + str(buy_value)

func _populate_description(desc : String, dmg : int, acc : float):
	var desc_label = $DescriptionBox/DescLabel
	var replace_string
	
	if desc.contains("{dmg}"):
		replace_string = desc.replacen("{dmg}", str(dmg))
		desc_label.text = replace_string
	else:
		desc_label.text = desc
		
	var acc_label = $DescriptionBox/AccLabel
	
	acc_label.text = "Acc " + str(int(acc * 100)) + "%"
		
	

func _empty_slot():
	is_empty = true
	$EmptyLabel.visible = true
	$EmptyRect.visible = true
	$BuyButton.visible = false
	$DescriptionBox.visible = false
