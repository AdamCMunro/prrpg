extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() - $Path2D.position
	var out_x
	var out_y
	
	out_x = - (mouse_pos.x - 960) * 0.75
	out_y = - (mouse_pos.y - 800)
	
	$Path2D.curve.set_point_out(0, Vector2(0, min(0, -out_y * 1.5)))
	
	$Path2D.curve.set_point_position(1, mouse_pos)
	$Path2D.curve.set_point_in(1, Vector2(0, 0))
	
	$Path2D/Line2D.points = $Path2D.curve.tessellate()
		
	
