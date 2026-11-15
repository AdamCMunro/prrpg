extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _slide_up():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", -480, 0.1).as_relative()
	tween.tween_property(self, "position:y", 20, 0.05).as_relative()
	
	return tween

func _slide_down():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:y", -20, 0.05).as_relative()
	tween.tween_property(self, "position:y", 480, 0.1).as_relative()
	
	return tween
	
