extends Node2D

var balance : int
var temp_balance :int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_label()
	
func _change_value(new_value):
	var starting_val = balance
	temp_balance = new_value
	var tween = create_tween()
	
	tween.tween_property(self, "balance", temp_balance, 0.45).from(starting_val)

func _update_label():
	$Label.text = "£" + str(balance)
