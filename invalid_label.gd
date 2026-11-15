extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _show():
	var tween = get_tree().create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	$Label.modulate.a = 0
	visible = true
	
	position = Vector2(960,450)
	
	tween.tween_property($Label, "modulate:a", 1, 0.1)
	tween.parallel().tween_property(self, "position:x", -20, 0.1).as_relative()
	tween.tween_property(self, "position:x", 30, 0.1).as_relative()
	tween.tween_property(self, "position:x", -15, 0.1).as_relative()
	tween.tween_property(self, "position:x", 15, 0.1).as_relative()
	tween.parallel().tween_property($Label, "modulate:a", 0, 0.1)
	
	await tween.finished
	
	visible = false
