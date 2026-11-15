class_name MoveData

extends Resource

enum Rarity
{
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY		
}

enum TargetType
{
	SELF,
	ALLY,
	ENEMY,
	ALL
}

enum BondTarget
{
	TARGET,
	ALL,
	RANDOM
}

@export var id: String = "" #back_end name for the move
@export var name: String = "" #the name shown in game
@export_multiline var description: String = "" #the text seen by the player when inspecting the move

@export var rarity: Rarity #enum for rarity
@export var element: int = 0 #integer where 0 = no element and every integer value represents some element

@export var number_of_targets: int = 0 #maximum number of targets the move will hit
@export var target_type: TargetType #enum for target type, ally can include self

@export var base_dmg_target: int = 0 #the amount of damage the move will do to target(s) prior to any modifiers (A negative number can be used to heal target(s))
@export var base_dmg_self: int = 0 #the amount of damage the move will do to the user prior to any modifiers (A negative number can be used to heal the user)
@export_range(0.0, 1.0) var base_acc: float = 0.0 #accuracy percentage represented by 0-1

@export var cooldown: int = 0 #number of turns required between uses
@export var charge_up: int = 0 #number of turns for attack to activate
@export var expiry: int = 0 #number of turns an attack lasts, 0 if there is no ongoing effect

@export var min_tension: int = 0 #amount of tension required for move to be used
@export var tension_cost: int = 0 #amount of tension consumed when used, will be <= min_tension. A negative number will increase tension

@export var bond_target: BondTarget #targeted friendly ,random, everyone
@export var min_bond: int = 0 #amount of bond required for move to be used
@export var bond_cost: int = 0 #amount of bond consumed when used, will be <= min_bond. A negative number will increase bond

func _use(user, target, type, squad, tension = null) -> int:
	if min_tension > tension.value:
		print("insufficient tension")
		return -1
	
	if target_type != TargetType.ALL:
		if target_type == TargetType.SELF and type != "SELF":
			print("invalid target")
			return -3
		elif target_type == TargetType.ALLY and type != "ALLY":
			if !(type == "SELF" and bond_cost == 0):
				print("invalid target")
				return -3
		elif target_type == TargetType.ENEMY and type != "ENEMY":
			print("invalid target")
			return -3
	
	if min_bond > 0:
		match bond_target:
			BondTarget.TARGET:
				if min_bond > squad._get_bond(user.index, target.index):
					print("insufficient bond")
					return -2
			BondTarget.RANDOM:
				var bond_rng = RandomNumberGenerator.new()
				var chosen = bond_rng.randi_range(0, squad.size() - 1)
				
				if min_bond > squad._get_bond(user.index, squad[chosen].index):
					print("insufficient bond")
					return -2
			BondTarget.ALL:
				var min = 99
				for s in squad.squad_slot_arr:
					if squad._get_bond(user.index, s.index)!= -1 and min > squad._get_bond(user.index, s.index):
						min = squad._get_bond(user.index, s.index)
				if min_bond > min:
					print("insufficient bond")
					return -2
	
	var rng = RandomNumberGenerator.new()
	var hit_chance = rng.randf_range(0.0, 1.0)
	
	if tension_cost != 0:
		tension._update_value(tension.value - tension_cost)
	
	if bond_cost != 0:
		match bond_target:
			BondTarget.TARGET:
				squad._update_bond(user.index, target.index, squad._get_bond(user.index, target.index) - bond_cost)
			BondTarget.RANDOM:
				var bond_rng = RandomNumberGenerator.new()
				var chosen = bond_rng.randi_range(0, squad.squad_slot_arr.size() - 1)
				
				squad._update_bond(user.index, squad.squad_slot_arr[chosen].index, squad._get_bond(user.index, squad.squad_slot_arr[chosen].index) - bond_cost)
			BondTarget.ALL:
				for s in squad.squad_slot_arr:
					squad._update_bond(user.index, s.index, squad._get_bond(user.index, s.index) - bond_cost)
		
	if charge_up > 0 and !user.is_charging:
		user.is_charging = true
		user.charge_count = charge_up
		user.charge_id = id
		return -4
	if charge_up > 0 and user.is_charging and user.charge_count == 0 and user.charge_id == id:
		user.is_charging = false
		user.charge_id = ""
		
	var acc = min(1.0, (base_acc + user.acc_mod))
	
	if hit_chance > acc:
		target._miss()
		return 1
	
	var target_arr = []
	
	if number_of_targets > 1:
		if number_of_targets == 3 and target_type == TargetType.ALLY:
			target_arr.append_array(squad.squad_slot_arr)
	else:
		target_arr.append(target)
	
	var total_damage
	
	for t in target_arr:
		if base_dmg_target > 0:
			total_damage = base_dmg_target + user.dmg_mod
			if t.is_defending:
				total_damage = floor(total_damage/2)
		else:
			total_damage = base_dmg_target
		
		if total_damage > 0: 
			t._take_damage(total_damage)
		elif total_damage < 0:
			t._recieve_heal(-total_damage)
		
	if base_dmg_self > 0:
		user._take_damage(base_dmg_self)
	elif base_dmg_self < 0:
		user._recieve_heal(-base_dmg_self)
		
	return 1
