class_name GameSettings

var board_size: Vector2i = Vector2i(8, 8)

#region Victory conditions
var victory_annihilation: bool = true

# Specific piece remaining
var victory_any_sacred: bool = false
var victory_all_sacred: bool = false
var victory_sacred_type: ChessPiece.ePieces = 0
#endregion

#region Turn rules
var turn_sequential: bool = true
var turns_concurrent: bool = false  # Turns are all taken at the same time
var turns_at_a_time: int = 1

var turn_bullet_chess: bool = false # Players have a time limit. They lose if it reaches 0.
var turn_bullet_limit: float = 0

var turn_queue: bool = false  # Players all queue up their moves, and all moves happen at once.
var turn_queue_time: float = 0

var turn_timed: bool = false  # Players take their turns after their cooldown runs out.
var turn_cooldown: float = 0
#endregion

var divine_wind: bool = false
var no_retreat: bool = false
var formation_broken: bool = false
var b_team: bool = false
var round_earth: bool = false
var polar_crossing: bool = false
var no_gods: bool = false
var greater_good: bool = false
var foreign_ground: bool = false
var brave_and_stupid: bool = false
var ho_chi_minh: bool = false

var can_players_edit: bool = false

func serialize() -> Dictionary:
	var d = {}
	d.board_size_x = board_size.x
	d.board_size_y = board_size.y
	
	d.divine_wind = divine_wind
	d.no_retreat = no_retreat
	d.formation_broken = formation_broken
	d.b_team = b_team
	d.round_earth = round_earth
	d.polar_crossing = polar_crossing
	d.no_gods = no_gods
	d.greater_good = greater_good
	d.foreign_ground = foreign_ground
	d.brave_and_stupid = brave_and_stupid
	d.ho_chi_minh = ho_chi_minh
	
	d.can_players_edit = can_players_edit
	
	d.victory_annihilation = victory_annihilation

	d.victory_sacred_type = victory_sacred_type
	d.victory_any_sacred = victory_any_sacred
	d.victory_all_sacred = victory_all_sacred

	d.turn_sequential = turn_sequential
	d.turns_concurrent = turns_concurrent
	d.turns_at_a_time = turns_at_a_time
	
	d.turn_bullet_chess = turn_bullet_chess
	d.turn_bullet_limit = turn_bullet_limit
	
	d.turn_queue = turn_queue
	d.turn_queue_time = turn_queue_time
	
	d.turn_timed = turn_timed
	d.turn_cooldown = turn_cooldown
	return d

static func deserialize(json_game_settings) -> GameSettings:
	var gs = GameSettings.new()
	# Getting default values here ensures presets made without this rules will still run.
	var x = json_game_settings.get("board_size_x", 8)
	var y = json_game_settings.get("board_size_y", 8)
	gs.board_size = Vector2i(x, y)
	
	gs.divine_wind = json_game_settings.get("divine_wind", false)
	gs.no_retreat = json_game_settings.get("no_retreat", false)
	gs.formation_broken = json_game_settings.get("formation_broken", false)
	gs.b_team = json_game_settings.get("b_team", false)
	gs.round_earth = json_game_settings.get("round_earth", false)
	gs.polar_crossing = json_game_settings.get("polar_crossing", false)
	gs.no_gods = json_game_settings.get("no_gods", false)
	gs.greater_good = json_game_settings.get("greater_good", false)
	gs.foreign_ground = json_game_settings.get("foreign_ground", false)
	gs.brave_and_stupid = json_game_settings.get("brave_and_stupid", false)
	gs.ho_chi_minh = json_game_settings.get("ho_chi_minh", false)
	
	gs.can_players_edit = json_game_settings.get("can_players_edit", false)
	
	gs.victory_annihilation = json_game_settings.get("victory_annihilation", true)

	gs.victory_sacred_type = json_game_settings.get("victory_sacred_type", 0)
	gs.victory_any_sacred = json_game_settings.get("victory_any_sacred", false)
	gs.victory_all_sacred = json_game_settings.get("victory_all_sacred", false)

	gs.turn_sequential = json_game_settings.get("turn_sequential", true)
	gs.turns_concurrent = json_game_settings.get("turns_concurrent", false)
	gs.turns_at_a_time = json_game_settings.get("turns_at_a_time", 1)
	
	gs.turn_bullet_chess = json_game_settings.get("turn_bullet_chess", false)
	gs.turn_bullet_limit = json_game_settings.get("turn_bullet_limit", 0)
	
	gs.turn_queue = json_game_settings.get("turn_queue", false)
	gs.turn_queue_time = json_game_settings.get("turn_queue_time", 0)
	
	gs.turn_timed = json_game_settings.get("turn_timed", false)
	gs.turn_cooldown = json_game_settings.get("turn_cooldown", 0)
	
	return gs
