extends Node2D

@onready var fight = get_parent()

var colour
var target_type
var attack_target
var user
var move

var standard_scale = Vector2(1,1)
var increased_scale = Vector2(1.5,1.5)

@export var rotation_speed: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Sprite2D.rotation += rotation_speed * delta
	$Shadow.rotation += rotation_speed * delta
	
	if Input.is_action_just_pressed("attack") and visible:
		var move_outcome = move._use(user, attack_target, target_type, user.get_parent(), fight.get_node("TensionBar"))
		
		match move_outcome:
			1:
				user._check_ability("ATTACK", "SELF")
				user._end_turn()
			-1:
				fight._show_invalid_label("insufficient tension")
			-2:
				fight._show_invalid_label("insufficient bond")
			-3:
				fight._show_invalid_label("invalid target")
			-4:
				user._end_turn()
		
		

func _change_colour(new_colour):
	colour = new_colour
	$Sprite2D.modulate = colour
	
func _change_target_type(new_type):
	target_type = new_type
	
	if target_type == "ALLY":
		scale = standard_scale
	else:
		scale = increased_scale
		
