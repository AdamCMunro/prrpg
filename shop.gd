extends Node2D

@onready var wallet = get_parent().get_node("Wallet")

var ally_slot_arr = []
var move_slot_arr = []

var ally_stock_arr = []
var move_stock_arr = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ally_node_arr = $AllyStock.get_children()
	var move_node_arr = $MoveStock.get_children()
	
	for i in range(1, 4):
		ally_slot_arr.append(ally_node_arr[i]) 
		move_slot_arr.append(move_node_arr[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _populate_shop():
	$Reroll._roll()
	
	for i in range(3):
		ally_slot_arr[i]._populate_slot(ally_stock_arr[i])
		move_slot_arr[i]._populate_slot(move_stock_arr[i])
	
