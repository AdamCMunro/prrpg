extends Node2D

const RAINBOW_BORDER_SHADER = preload("res://shaders/charged_move.gdshader")

var mouse_over_scale = Vector2(1.05,1.05)
var normal_scale = Vector2(1,1)

var mouse_over = false
var changing_scale = false

var disabled = false

var scale_tween : Tween

var selected = false

var move_id = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !changing_scale and !disabled:
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
			if !disabled:
				_press()

func _press():
	changing_scale = true
	await _animate_scale_change(scale, normal_scale).finished
	await get_parent()._hide_moves().finished
	changing_scale = false
	_select_move()

func _select_move():
	selected = true
	get_parent()._show_move_info(move_id)
	
func _disable():
	disabled = true
	$DisabledRect.visible = true
	$Label.visible = false
	
func _add_rainbow_border():
	var override_material = ShaderMaterial.new()
	override_material.shader = RAINBOW_BORDER_SHADER
	
	$ColorRect.set_material(override_material)
	
	
func _remove_rainbow_border():
	var override_material = ShaderMaterial.new()
	
	$ColorRect.set_material(override_material)
	
	
	
