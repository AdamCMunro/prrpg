extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	visible = false
	get_parent().get_node("Squad").visible = true
	get_parent().get_node("Squad")._wipe_squad()
	get_parent().get_node("Wallet").visible = true
	get_parent()._start_fight()


func _on_button_2_pressed() -> void:
	visible = false
	get_parent().get_node("Squad").visible = true
	get_parent().get_node("Squad")._wipe_squad()
	get_parent().get_node("Wallet").visible = true
	get_parent().get_node("Wallet")._change_value(5000)
	get_parent()._go_to_shop()
