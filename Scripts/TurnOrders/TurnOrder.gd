class_name TurnOrder

signal on_turn_start(p: Player)
signal on_turn_end(p: Player)

var players_by_gid: Dictionary:
	get:
		var r = {}
		for p in players:
			r[p.game_id] = p
		return r
var players: Array = []
var victory_condition: VictoryCondition

func _init(players_by_game_id: Dictionary, victory_condition: VictoryCondition):
	players = Player.players.keys()
	players.sort_custom(_sort_players_by_gid)
	self.victory_condition = victory_condition
	
func _sort_players_by_gid(a, b) -> bool:
	return a.game_id <= b.game_id
	
func _get_turn_id(player: Player) -> int:
	for i in players.size():
		var p = players[i]
		if p == player:
			return i
	return -1
	
func turn_taken(id: int):
	pass

# When a player leaves, or is defeated.
func remove_player(id: int):
	pass
