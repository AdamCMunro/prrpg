extends Node2D

const SHINE_SHADER = preload("res://shaders/shine.gdshader")

var mouse_over = false
var changing_scale = false

var mouse_over_scale = Vector2(1.1,1.1)
var normal_scale = Vector2(1,1)

var scale_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !changing_scale:
		if mouse_over and scale != mouse_over_scale:
			changing_scale = true
			await _animate_scale_change(scale, mouse_over_scale).finished
			changing_scale = false
		elif !mouse_over and scale != normal_scale:
			changing_scale = true
			await _animate_scale_change(scale, normal_scale).finished
			changing_scale = false
			
func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	$Sprite2D.texture = load("res://assets/end_turn_hover.png")
	$Sprite2D.position.y -= 15

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	$Sprite2D.texture = load("res://assets/end_turn.png")
	$Sprite2D.position.y += 15

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() && not event.is_echo():
			_press()
			
func _press():
	_remove_shine()
	var fight = get_parent()
	changing_scale = true
	$Sprite2D.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play()
	await get_tree().create_timer(0.34).timeout
	await _slide_out().finished
	$Sprite2D.visible = true
	$AnimatedSprite2D.visible = false
	_animate_scale_change(scale, normal_scale)
	fight.squad._end_turn()
	fight.squad._check_squad_abilities("TURN_END", "GAME", null)
	changing_scale = false
	
	await get_tree().create_timer(0.5).timeout
	
	fight._start_enemy_turn()

func _slide_out():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:x", -20, 0.05).as_relative()
	tween.tween_property(self, "position:x", 300, 0.1).as_relative()
	
	return tween
	
func _slide_in():
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "position:x", -300, 0.1).as_relative()
	tween.tween_property(self, "position:x", 20, 0.05).as_relative()
	
	return tween



func _animate_scale_change(current_scale, new_scale):
	
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
		
	scale_tween = get_tree().create_tween()
	
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	
	if current_scale > new_scale:
		scale_tween.tween_property(self, "scale", current_scale * 1.1, 0.05)
		scale_tween.tween_property(self, "scale", new_scale * 0.95, 0.1)
		scale_tween.tween_property(self, "scale", new_scale, 0.05)
	else:
		scale_tween.tween_property(self, "scale", current_scale * 0.95, 0.05)
		scale_tween.tween_property(self, "scale", new_scale * 1.1, 0.1)
		scale_tween.tween_property(self, "scale", new_scale, 0.05)
	
	return scale_tween

func _shine():
	var override_material = ShaderMaterial.new()
	override_material.shader = SHINE_SHADER
	$Sprite2D.set_material(override_material)
	
func _remove_shine():
	var override_material = ShaderMaterial.new()
	$Sprite2D.set_material(override_material)


	
