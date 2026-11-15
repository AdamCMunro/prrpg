extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_value(new_value):
	_update_value_label(new_value)
	
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	if $ProgressBar.value > new_value:
		if $ProgressBar.value != get_parent().max_hp:
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
	
func _update_value_label(new_value):
	if get_parent().max_hp >= 10 and new_value < 10:
		$Label.text = "0" + str(new_value) + "/" + str(get_parent().max_hp)
	elif get_parent().max_hp >= 10:
		$Label.text = str(new_value) + "/" + str(get_parent().max_hp)
