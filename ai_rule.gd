class_name AiRule

extends Resource

enum ConditionType
{
	HEALTH_BELOW,
	HEALTH_ABOVE,
	HAS_STATUS,
	ALWAYS
}

enum ConditionTarget
{
	SELF,
	ALLY,
	ENEMY
}

enum ActionTargetType
{
	SELF,
	ALLY,
	ENEMY,
	ALL
}

enum ActionTarget
{
	RANDOM,
	LOWEST_HP,
	HIGHEST_HP,
	WITH_STATUS
}

@export var condition_type : ConditionType #condition to check
@export var condition_target : ConditionTarget #target to check condition against
@export_range(0.0, 1.0) var chance : float = 1.0 #chance of following order

@export var action_target_type : ActionTargetType #type of target
@export var action_target : ActionTarget #how target will be chosen

@export_range(0.0, 1.0) var threshold : float = 1.0 #measurment of condition

@export var action : MoveData

var target

func _condition_met(user, squad):
	var con_target
	
	if !_calc_chance():
		return false
	
	if condition_type == ConditionType.ALWAYS:
		target = _choose_target(user, squad)
		return true
	
	if condition_target == ConditionTarget.SELF:
		con_target = user
		
		match condition_type:
			ConditionType.HEALTH_BELOW:
				if (user.current_hp/user.max_hp) < threshold:
					target = _choose_target(user, squad)
					return true
			ConditionType.HEALTH_ABOVE:
				if (user.current_hp/user.max_hp) >= threshold:
					target = _choose_target(user, squad)
					return true
			ConditionType.HAS_STATUS:
				pass
				#we'll figure out status effects later
		
		
	if condition_target == ConditionTarget.ALLY:
		pass
		#we'll figure out multiple enemies later
	else:
		con_target = squad
		
		for s in squad:
			match condition_type:
				ConditionType.HEALTH_BELOW:
					if (s.current_hp/s.max_hp) < threshold:
						target = _choose_target(user, squad)
						return true
				ConditionType.HEALTH_ABOVE:
					if (s.current_hp/s.max_hp) >= threshold:
						target = _choose_target(user, squad)
						return true
				ConditionType.HAS_STATUS:
					pass
					#we'll figure out status effects later
	
	return false
		

func _choose_target(user, squad):
	
	var target_arr = []
	
	match action_target_type:
		ActionTargetType.SELF:
			return user
		ActionTargetType.ALLY:
			pass
			#we'll figure out multiple enemies later
		ActionTargetType.ENEMY:
			for s in squad:
				if !s.is_empty and !s.is_down:
					target_arr.append(s)
		ActionTargetType.ALL:
			for s in squad:
				if !s.is_empty and !s.is_down:
					target_arr.append(s)
			target_arr.append(user)
		
	match action_target:
		ActionTarget.RANDOM:
			var rng = RandomNumberGenerator.new()
			var random_choice = rng.randi_range(0, target_arr.size() - 1)
			var valid_target = false
			while !valid_target:
				if !target_arr[random_choice].is_down:
					valid_target = true
				else:
					random_choice = rng.randi_range(0, target_arr.size() - 1)
			
			return target_arr[random_choice]
		ActionTarget.LOWEST_HP:
			var min_hp_target = target_arr[0]
			for i in range(1, target_arr.size()):
				if target_arr[i].current_hp < min_hp_target.current_hp and !target_arr[i].is_down:
					min_hp_target = target_arr[i]
			
			return min_hp_target
		ActionTarget.HIGHEST_HP:
			var max_hp_target = target_arr[0]
			for i in range(1, target_arr.size()):
				if target_arr[i].current_hp > max_hp_target.current_hp:
					max_hp_target = target_arr[i]
			
			return max_hp_target
		ActionTarget.WITH_STATUS:
			pass
				#we'll figure out status effects later
	
	return null
		
						
			

func _calc_chance():
	var rng = RandomNumberGenerator.new()
	var hit_chance = rng.randf_range(0.0, 1.0)
	
	if hit_chance > chance:
		return false
	else:
		return true

func _get_target():
	return target
	
func _get_target_type() -> String:
	match action_target_type:
		ActionTargetType.SELF:
			return "SELF"
		ActionTargetType.ALLY:
			return "ALLY"
		ActionTargetType.ENEMY:
			return "ENEMY"
		ActionTargetType.ALL:
			return "ALL"
	return ""

		

	
