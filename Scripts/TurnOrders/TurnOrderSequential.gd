class_name TurnOrderSequential
extends TurnOrder

var current_player_class: Player = null
var current_player: int = -1
var turns_per_player: int = 1

func _init(players_by_game_id: Dictionary, victory_condition: VictoryCondition, turns_per_player: int):
	super(players_by_game_id, victory_condition)
	self.turns_per_player = turns_per_player
	find_next_valid_player(-1)

func turn_taken(id: int):
	if current_player != id:
		print("Tried to progress the turn for player " + str(id) + " while it is player " + str(current_player) + "'s turn")
		return
	# TODO: Handle no player being able to act
	
	# Progress this player's action state.
	if players_by_gid.has(id):
		var p = players_by_gid[id]
		if p.actions_remaining <= 0:
			return
		p.actions_remaining -= 1
		p.player_stats.turns_taken += 1
		p.player_stats.total_turn_time += Time.get_ticks_msec() - p.action_start_time
		
		# Is turn finished?
		if p.actions_remaining <= 0:
			on_turn_end.emit(p)
		else:
			p.action_start_time = Time.get_ticks_msec()
			return
		
	# Find next valid player
	find_next_valid_player(current_player)

func find_next_valid_player(from_id: int):
	for i in range(players.size()):
		var next_id = wrapi(int(from_id) + i + 1, 0, players.size())
		var next_player = players[next_id]
		if victory_condition.defeated.has(next_player.game_id):
			continue
		if not next_player.can_act():
			var m = ColorController.color_text(next_player.character_name, next_player.color)
			m += " cannot act. Skipping turn."
			MessageController.add_message(m)
			continue
			
		current_player = next_id
		current_player_class = next_player
		next_player.actions_remaining = turns_per_player
		next_player.action_start_time = Time.get_ticks_msec()
		on_turn_start.emit(next_player)
		return

func remove_player(gid: int):
	var should_progress_player = false
	if current_player_class.game_id == gid:
		should_progress_player = true
	
	for i in range(players.size()):
		var p = players[i]
		if p.game_id == gid:
			p.actions_remaining = 0
			p.defeated = true
			players.pop_at(i)
			break
		
	if should_progress_player:
		find_next_valid_player(current_player - 1)
