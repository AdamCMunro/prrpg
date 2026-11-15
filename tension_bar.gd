extends Node2D

const RAINBOW_SHADER = preload("res://shaders/tension_bar.gdshader")

var value = 0
var max_tension = 10

var bar_filled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_max_tension(max_tension)
	
	#await get_tree().create_timer(4).timeout
	#_update_value(max_tension)
	#await get_tree().create_timer(4).timeout
	#_update_value(max_tension/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_value_label():
	if max_tension >= 10 and value < 10:
		$ValueLabel.text = "0" + str(value) + "/" + str(max_tension)
	else:
		$ValueLabel.text = str(value) + "/" + str(max_tension)

func _update_max_tension(new_max):
	max_tension = new_max
	$ProgressBar.max_value = new_max
	_update_value_label()
	
func _update_value(new_value):
	if new_value > max_tension:
		value = max_tension
	else:
		value = new_value
	
	_update_value_label()
	
	if value != max_tension and bar_filled:
		_remove_full_bar_effect()
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if $ProgressBar.value > new_value:
		if $ProgressBar.value != max_tension:
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
		
	if value == max_tension and !bar_filled:
		_add_full_bar_effect()
		
func _add_full_bar_effect():
	bar_filled = true
	
	var object_arr = [$ProgressBar, $ValueLabel]
	var override_material = ShaderMaterial.new()
	override_material.shader = RAINBOW_SHADER
	
	$TensionLabel.text = "[shake rate=20.0 level=10 connected=0]tension[/shake]"
	
	for obj in object_arr:
		obj.set_material(override_material)
	
	
func _remove_full_bar_effect():
	bar_filled = false
	
	$TensionLabel.text = "tension"
	
	var object_arr = [$ProgressBar, $ValueLabel]
	var override_material = ShaderMaterial.new()
	
	for obj in object_arr:
		obj.set_material(override_material)
	
