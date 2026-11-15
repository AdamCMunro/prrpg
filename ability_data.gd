class_name AbilityData

extends Resource

var Buff = load("res://buff.gd")

enum ConditionType
{
	DAMAGED,
	HEALED,
	KILLED,
	TURN_END,
	ATTACK,
	DEFEND,
	HAS_STATUS,
	ROUND_END,
	ROUND_START,
	TENSION,
	HEALTH_ABOVE,
	HEALTH_BELOW,
	BOUGHT,
	SOLD,
	MISSED,
	MAX_HEALTH,
	MAX_TENSION
}

enum ConditionTarget
{
	SELF,
	ENEMY,
	ALLY,
	ALL,
	GAME
}

enum EffectTargetType
{
	SELF,
	ENEMY,
	ALLY,
	ALL
}

enum EffectTarget
{
	CHOSEN,
	RANDOM,
	ALL,
	HIGHEST_HP,
	LOWEST_HP,
	HIGHEST_BOND,
	LOWEST_BOND,
	HAS_STATUS
}

enum Stat
{
	MAX_HP,
	CURRENT_HP,
	BOND,
	DMG_MOD,
	TENSION,
	ACCURACY_MOD
}

@export var condition_type : ConditionType
@export var condition_target : ConditionTarget

@export var use_threshold_pct: bool = false
@export_range(0.0, 1.0) var threshold_pct : float = 1.0
@export var use_threshold: bool = false
@export var threshold : int = 0

@export var effect_target_type : EffectTargetType
@export var effect_target : EffectTarget

@export_range(0.0, 1.0) var chance : float = 1.0

@export var stats_effect : Array[Stat]

@export var modifier : Array[int]

@export var has_reset_condition: bool = false

@export var reset_condition_type : ConditionType
@export var reset_condition_target : ConditionTarget

@export_range(0.0, 1.0) var reset_chance : float = 0.0

@export var has_unique_ability : bool = false
@export var unique_ability : Script

var target = []

func _condition_met(con : String, con_tgt_type : String, user, squad, enemy, tension = null, round = 0, turn = 0, tgt = null):
	var con_target = []
	
	if user.is_down:
		if con != "HEALTH" and user.current_hp == 0:
			return false
	
	if !_calc_chance(chance):
		return false
	
	if con != _get_condition_type(condition_type):
		return false
	
	if con_tgt_type != _get_condition_target(condition_target):
		return false
	
	if use_threshold_pct:
			match condition_type:
				ConditionType.TENSION:
					if tension.value/tension.max_tension < threshold_pct:
						return false
	elif use_threshold:
			match condition_type:
				ConditionType.ROUND_START, ConditionType.ROUND_END:
					if round < threshold:
						return false
				ConditionType.TURN_END:
					if turn < threshold:
						return false
				ConditionType.TENSION:
					if tension.value < threshold:
						return false
	
	match condition_target:
		ConditionTarget.SELF:
			con_target.append(user)
		ConditionTarget.ENEMY:
			con_target.append(enemy)
		ConditionTarget.ALLY:
			for s in squad:
				if !s.is_empty:
					con_target.append(s)
		ConditionTarget.ALL:
			for s in squad:
				if !s.is_empty:
					con_target.append(s)
			con_target.append(enemy)
	
	for ct in con_target:
		
		if use_threshold_pct:
			match condition_type:
				ConditionType.HEALTH_ABOVE:
					if ct.current_hp/ct.max_hp < threshold_pct:
						return false
				ConditionType.HEALTH_BELOW:
					if ct.current_hp/ct.max_hp > threshold_pct:
						return false
		elif use_threshold:
			match condition_type:
				ConditionType.HEALTH_ABOVE:
					if ct.current_hp < threshold:
						return false
				ConditionType.HEALTH_BELOW:
					if ct.current_hp > threshold:
						return false
	
	if has_unique_ability:
		unique_ability._use(user, enemy, squad, tgt, tension)
	else:
		_effect(user, enemy, squad, tgt, tension)
	
	return true

func _reset_condition_met(con : String, user, squad, enemy, tension = 0)	:
	var con_target
	
	if !has_reset_condition:
		return false
	
	if !_calc_chance(reset_chance):
		return false
		
	if con != _get_condition_type(reset_condition_type):
		return false


func _effect(user, enemy, squad, tgt, tension):
	var eff_target = []
	
	match effect_target_type:
		EffectTargetType.SELF:
			eff_target.append(user)
		EffectTargetType.ENEMY:
			eff_target.append(enemy)
		EffectTargetType.ALLY:
			for s in squad:
				eff_target.append(s)
		EffectTargetType.ALL:
			for s in squad:
				eff_target.append(s)
			eff_target.append(enemy)
			
	match effect_target:
		EffectTarget.CHOSEN:
			target.append(tgt)
		EffectTarget.RANDOM:
			var rng = RandomNumberGenerator.new()
			var tgt_choice = rng.randi_range(0, eff_target.size())
			target.append(eff_target[tgt_choice])
		EffectTarget.ALL:
			target = eff_target
		EffectTarget.HIGHEST_HP:
			var high_hp = eff_target[0]
			for et in eff_target:
				if et.current_hp > high_hp.current_hp:
					high_hp = et
			target.append(high_hp)
		EffectTarget.LOWEST_HP:
			var low_hp = eff_target[0]
			for et in eff_target:
				if et.current_hp < low_hp.current_hp:
					low_hp = et
			target.append(low_hp)
		EffectTarget.HIGHEST_BOND:
			pass
			#we'll deal with bonds later
		EffectTarget.LOWEST_BOND:
			pass
			#we'll deal with bonds later
		EffectTarget.HAS_STATUS:
			pass
			#we'll deal with status effects later
		_:
			target = eff_target
	
	var new_buff
	
	for t in target:
		for i in range(stats_effect.size()):
			match stats_effect[i]:
				Stat.MAX_HP:
					t.max_hp += modifier[i]
					new_buff = Buff.new(t.id, stats_effect[i], modifier[i])
					t._add_buff(new_buff)
				Stat.CURRENT_HP:
					t._recieve_heal(modifier[i])
				Stat.BOND:
					user.get_parent()._update_bond(user.index, t.index, user.get_parent()._get_bond(user.index, t.index) + modifier[i])
				Stat.DMG_MOD:
					t.dmg_mod += modifier[i]
					new_buff = Buff.new(t.id, stats_effect[i], modifier[i])
					t._add_buff(new_buff)
				Stat.TENSION:
					tension._update_value(tension.value + modifier[i])
				Stat.ACCURACY_MOD:
					t.acc_mod += modifier[i]
					new_buff = Buff.new(t.id, stats_effect[i], modifier[i])
					t._add_buff(new_buff)

func _reset():
	pass
	
func _calc_chance(value):
	var rng = RandomNumberGenerator.new()
	var hit_chance = rng.randf_range(0.0, 1.0)
	
	if hit_chance > value:
		return false
	else:
		return true

func _get_target():
	return target
	
func _get_condition_type(con : ConditionType) -> String:
	
	match con:
		ConditionType.DAMAGED:
			return "DAMAGED"
		ConditionType.HEALED:
			return "HEALED"
		ConditionType.KILLED:
			return "KILLED"
		ConditionType.TURN_END:
			return "TURN_END"
		ConditionType.ATTACK:
			return "ATTACK"
		ConditionType.DEFEND:
			return "DEFEND"
		ConditionType.HAS_STATUS:
			return "HAS_STATUS"
		ConditionType.ROUND_END:
			return "ROUND_END"
		ConditionType.ROUND_START:
			return "ROUND_START"
		ConditionType.TENSION:
			return "TENSION"
		ConditionType.HEALTH_ABOVE:
			return "HEALTH_ABOVE"
		ConditionType.HEALTH_BELOW:
			return "HEALTH_BELOW"
		ConditionType.BOUGHT:
			return "BOUGHT"
		ConditionType.SOLD:
			return "SOLD"
		ConditionType.MISSED:
			return "MISSED"	
		ConditionType.MAX_HEALTH:
			return "MAX_HEALTH"
		ConditionType.MAX_TENSION:
			return "MAX_TENSION"
		
	
	return ""
	
func _get_condition_target(tgt : ConditionTarget) -> String:
	
	match tgt:
		ConditionTarget.SELF:
			return "SELF"
		ConditionTarget.ENEMY:
			return "ENEMY"
		ConditionTarget.ALLY:
			return "ALLY"
		ConditionTarget.ALL:
			return "ALL"
		ConditionTarget.GAME:
			return "GAME"
	
	return ""
