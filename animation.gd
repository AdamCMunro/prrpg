extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _play(pos):
	position = pos + Vector2(75,0)
	visible = true
	$AnimatedSprite2D.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false
