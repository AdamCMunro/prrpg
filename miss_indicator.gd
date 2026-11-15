extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _animate_miss_label(pos):
	position = pos + Vector2(0,-120)
	visible = true
	
	var tween = get_tree().create_tween()
		
	tween.tween_property(self, "position:x", -25, 0.05).as_relative()
	tween.tween_property(self, "position:x", 50, 0.05).as_relative()
	tween.tween_property(self, "position:x", -35, 0.05).as_relative()
	tween.tween_property(self, "position:x", 15, 0.05).as_relative()
	tween.tween_property(self, "position:x", -5, 0.05).as_relative()
	
	await tween.finished
	
	visible = false
