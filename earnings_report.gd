extends Node2D

#basic +£300 (maybe £600 for a boss)
#"early finish" starting at +£500 and then decreasing by £125 for every turn after the first
#'health and safety' : +£150 awarded if you end the fight with everyone at full health
#'First Aid' : -£150 for everyone down at the end of the round
#Interest : 5% of total money (with limit maybe?)
#'Income Tax' : -10% of earnings

const BASIC_PAYOUT = 300
const BOSS_PAYOUT = 600
const EARLY_FINISH_PAYOUT = 500
const HEALTH_SAFETY_PAYOUT = 150
const FIRST_AID_PAYOUT = -150
var interest = 0.05
var tax = 0.1

@onready var fight = get_parent().get_parent()
@onready var wallet = fight.get_parent().get_node("Wallet")

var is_calculated = false
var earnings = 0
var temp_total = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_calculated:
		_update_total_label()
	
func _calc_earnings():
	var earnings_arr = []
	
	$FightCompleted.visible = true
	$FightCompleted/ValueLabel.text = "£" + str(BASIC_PAYOUT)
	earnings += BASIC_PAYOUT
	earnings_arr.append($FightCompleted)
	
	var early_finish = EARLY_FINISH_PAYOUT - (125 * (fight.turn_number - 1))
	if early_finish > 0:
		$EarlyFinish.visible = true
		$EarlyFinish/ValueLabel.text = "£" + str(early_finish)
		earnings += early_finish
		earnings_arr.append($EarlyFinish)
	
	var health_safety = HEALTH_SAFETY_PAYOUT
	var first_aid = 0
	
	for s in fight.squad.squad_slot_arr:
		if s.current_hp < s.max_hp:
			health_safety = 0
			if s.is_down:
				first_aid += FIRST_AID_PAYOUT
	
	if health_safety > 0:
		$HealthSafety.visible = true
		$HealthSafety/ValueLabel.text = "£" + str(HEALTH_SAFETY_PAYOUT)
		earnings += HEALTH_SAFETY_PAYOUT
		earnings_arr.append($HealthSafety)
	
	if first_aid < 0:
		$FirstAid.visible = true
		$FirstAid/ValueLabel.text = "-£" + str(-1 * first_aid)
		earnings += first_aid
		earnings_arr.append($FirstAid)
	
	var intrst : int = floor(interest * wallet.balance)
	
	if intrst > 0:
		$Interest.visible = true
		$Interest/ValueLabel.text = "£" + str(intrst)
		earnings += intrst
		earnings_arr.append($Interest)
	
	var income_tax : int = floor(earnings * tax)
	
	$IncomeTax.visible = true
	$IncomeTax/ValueLabel.text = "-£" + str(income_tax)
	earnings -= income_tax
	earnings_arr.append($IncomeTax)
	
	is_calculated = true
	
	_animate_earnings(earnings_arr)
	
	var tween = create_tween()
	
	tween.tween_property(self, "temp_total", earnings, 1)
	
func _reset_earnings():
	is_calculated = false
	earnings = 0
	temp_total = 0
	$FightCompleted.visible = false
	$EarlyFinish.visible = false
	$HealthSafety.visible = false
	$FirstAid.visible = false
	$Interest.visible = false
	$IncomeTax.visible = false

func _animate_earnings(arr):
	var delay = 0.2
	var offset = 25
	
	for obj in arr:
		obj.position.y = 2000
	
	for i in range(arr.size()):
		await get_tree().create_timer(delay * i).timeout
		var tween = create_tween()
		tween.tween_property(arr[i], "position:y", 0 + (offset * i) - 10, 0.15)
		tween.tween_property(arr[i], "position:y", 0 + (offset * i), 0.05)

func _update_total_label():
	$Total.text = "£" + str(temp_total)
	
	
	
	
	
	
