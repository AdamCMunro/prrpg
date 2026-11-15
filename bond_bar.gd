extends Node2D

const RAINBOW_SHADER = preload("res://shaders/bond_bar.gdshader")

var value = 0
var max_bond = 8

var bar_filled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_max_bond(new_max):
	max_bond = new_max
	
func _update_value(new_value):
	value = min(new_value, max_bond)
	
	if value != max_bond and bar_filled:
		_remove_full_bar_effect()
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if $ProgressBar.value > new_value:
		if $ProgressBar.value != max_bond:
			tween.tween_property($ProgressBar, "value", $ProgressBar.value + 0.25, 0.05)
		if new_value != 0:
			tween.tween_property($ProgressBar, "value", new_value - 0.25, 0.1)
			tween.tween_property($ProgressBar, "value", new_value, 0.05)
		else:
			tween.tween_property($ProgressBar, "value", new_value, 0.1)
	elif $ProgressBar.value < new_value:
		if $ProgressBar.value != 0:
			tween.tween_property($ProgressBar, "value", $ProgressBar.value - 0.25, 0.05)
		if new_value != 10:
			tween.tween_property($ProgressBar, "value", new_value + 0.25, 0.1)
			tween.tween_property($ProgressBar, "value", new_value, 0.05)
		else:
			tween.tween_property($ProgressBar, "value", new_value, 0.1)
			
	await tween.finished
		
	if value == max_bond and !bar_filled:
		_add_full_bar_effect()
		
func _add_full_bar_effect():
	bar_filled = true
	
	var override_material = ShaderMaterial.new()
	override_material.shader = RAINBOW_SHADER

	$ProgressBar.set_material(override_material)
	
	
func _remove_full_bar_effect():
	bar_filled = false

	var override_material = ShaderMaterial.new()
	
	$ProgressBar.set_material(override_material)
	
