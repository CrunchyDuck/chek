class_name AIPlayer
extends Player

var reaction_time: float = 1  # Try to move every x seconds
var reaction_timer: float = 2

var rng = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	if not can_move:
		return
	reaction_timer -= delta
	if reaction_timer <= 0:
		reaction_timer += reaction_time
		try_move()
		
func try_move():
	if not can_move:
		return	

	var candidates = pieces.duplicate()
	while candidates.size() > 0:
		var index = rng.randi_range(0, candidates.size()-1)
		var piece = candidates.pop_at(index)
		var actions = piece._get_actions()
		if actions.size() > 0:
			var planned_action = actions[rng.randi_range(0, actions.size() - 1)]
			if board.perform_action(planned_action):
				return
	
