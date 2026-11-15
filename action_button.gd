extends Node2D

var mouse_over_scale = Vector2(1.05,1.05)
var normal_scale = Vector2(1,1)

var mouse_over = false
var changing_scale = false

var scale_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !changing_scale:
		if mouse_over and scale != mouse_over_scale:
			changing_scale = true
			$HoverRect.visible = true
			await _animate_scale_change(scale, mouse_over_scale).finished
			changing_scale = false
		elif !mouse_over and scale != normal_scale:
			changing_scale = true
			$HoverRect.visible = false
			await _animate_scale_change(scale, normal_scale).finished
			changing_scale = false


func _on_area_2d_mouse_entered() -> void:
	mouse_over = true

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false


func _animate_scale_change(current_scale, new_scale):
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
		
	scale_tween = get_tree().create_tween()
	
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	
	if current_scale > new_scale:
		scale_tween.tween_property(self, "scale", current_scale * 1.05, 0.05)
		scale_tween.tween_property(self, "scale", new_scale * 0.95, 0.1)
		scale_tween.tween_property(self, "scale", new_scale, 0.05)
	else:
		scale_tween.tween_property(self, "scale", current_scale * 0.95, 0.05)
		scale_tween.tween_property(self, "scale", new_scale * 1.05, 0.1)
		scale_tween.tween_property(self, "scale", new_scale, 0.05)
	
	return scale_tween


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			_press()

func _press():
	changing_scale = true
	await _animate_scale_change(scale, normal_scale).finished
	await get_parent()._hide_buttons().finished
	changing_scale = false
	if $Label.text == "fight":
		get_parent()._show_moves()
	else:
		var squad = get_parent().get_parent().get_parent().get_node("Squad")
		
		squad.selected._defend()		
				
				
