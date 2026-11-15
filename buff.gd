class_name Buff

enum Stat
{
	MAX_HP,
	CURRENT_HP,
	BOND,
	DMG_MOD,
	TENSION,
	ACCURACY_MOD
}

var source : String = ""
var stat : Stat
var value : float = 0.0
var transferable = false

func _init(new_source : String = "", new_stat : Stat = 0, new_value : float = 0.0, new_transfer = false):
	source = new_source
	stat = new_stat
	value = new_value
	transferable = new_transfer
	
