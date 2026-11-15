extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _animate_dmg_label(pos):
	position = pos + Vector2(100,-120)
	visible = true
	
	var tween = get_tree().create_tween()
		
	tween.tween_property(self, "position:y", -25, 0.05).as_relative()
	tween.tween_property(self, "position:y", 75, 0.05).as_relative()
	tween.tween_property(self, "position:y", -10, 0.05).as_relative()
	tween.tween_property(self, "position:y", 5, 0.05).as_relative()
	
	await tween.finished
	
	visible = false
	
