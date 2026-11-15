class_name AiData

extends Resource

@export var rules : Array[AiRule] #list of rules to follow  

func _take_action(user, squad):
	for rule in rules:
		if rule._condition_met(user, squad):
			user._show_enemy_action_box(rule.action, rule._get_target())
			rule.action._use(user, rule._get_target(), rule._get_target_type(), squad[0].get_parent(), user.get_parent().get_node("TensionBar"))
