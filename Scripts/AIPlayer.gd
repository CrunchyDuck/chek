extends Node

var controller: GameController = null

var move_time: float = 1  # Try to move every x seconds
var move_timer: float = 0

var pieces: Array[ChessPiece] = []
var can_move: bool = false  # This should be a property later.
var rng = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	move_timer -= delta
	if move_timer <= 0:
		move_timer += move_time
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
			
	
