extends Node2D

const RAINBOW_SHADER = preload("res://shaders/effect.gdshader")

var mouse_over = false
var is_empty = true
var id = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_over and !is_empty:
		_populate_desc_box()
		get_parent().get_node("MoveDescriptionBox").visible = true


func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	
func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	get_parent().get_node("MoveDescriptionBox").visible = false
	

func _populate_desc_box():
	var desc_box = get_parent().get_node("MoveDescriptionBox")
	var move_data = get_parent().get_parent().get_parent().get_parent()._get_move_data(id)
	var ally_dmg = get_parent().get_parent().dmg_mod
	var ally_acc = get_parent().get_parent().acc_mod
	
	_populate_descriptions(desc_box, move_data.description, move_data.base_dmg_target, move_data.base_acc, ally_dmg, ally_acc)
	_populate_rarity(desc_box, move_data.rarity)
	

func _populate_rarity(desc_box, rarity):
	var override_material = ShaderMaterial.new()
	var str : String
	var color : String
	var pre_string : String
	var post_string : String = "[/color]"
	match rarity:
		0:
			str = "common"
			color = "666666ff"
		1:
			str = "uncommon"
			color = "1a8066ff"
		2:
			str = "rare"
			color = "1a66b3ff"
		3:
			str = "epic"
			color = "1a66b3ff"
		4:
			str = "Legendary"
			color = "ffffffff"
			override_material.shader = RAINBOW_SHADER
	
	pre_string = "[color=" + color + "]"
	desc_box.get_node("RarityLabel").text = pre_string + str + post_string
	desc_box.get_node("RarityLabel").set_material(override_material)

func _populate_descriptions(desc_box, move_desc : String, move_dmg: int, move_acc : float, ally_dmg : int, ally_acc : float):
	var replace_string
	
	var move_label = desc_box.get_node("DescLabel")
	var move_replace_string
	
	if move_desc.contains("{dmg}"):
		move_replace_string = move_desc.replacen("{dmg}", str(ally_dmg + move_dmg))
		move_label.text = move_replace_string
	else:
		move_label.text = move_desc
	
	desc_box.get_node("AccLabel").text = "Acc " + str(int((min(1, move_acc + ally_acc) * 100))) + "%"
