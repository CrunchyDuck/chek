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
var turn_concurrent: bool = false  # Turns are all taken at the same time
var turn_queue: bool = false  # Players all queue up their moves, and all moves happen at once.
var turn_cooldown: bool = false  # Turns are all taken at the same time

var turns_at_a_time: int = 1
var turn_queue_time: float = 0
var turn_cooldown_time: float = 0
#endregion

var turn_bullet_chess: bool = false # Players have a time limit. They lose if it reaches 0.
var turn_bullet_limit: float = 0

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
var patience: bool = false

var can_players_edit: bool = false

func serialize() -> Dictionary:
	var d = {}
	d.board_size_x = board_size.x
	d.board_size_y = board_size.y
	
	d.victory_annihilation = victory_annihilation
	
	d.victory_any_sacred = victory_any_sacred
	d.victory_all_sacred = victory_all_sacred
	d.victory_sacred_type = victory_sacred_type

	d.turn_sequential = turn_sequential
	d.turn_concurrent = turn_concurrent  # Turns are all taken at the same time
	d.turn_queue = turn_queue  # Players all queue up their moves, and all moves happen at once.
	d.turn_cooldown = turn_cooldown  # Turns are all taken at the same time

	d.turns_at_a_time = turns_at_a_time
	d.turn_queue_time = turn_queue_time
	d.turn_cooldown_time = turn_cooldown_time
	
	d.turn_bullet_chess = turn_bullet_chess
	d.turn_bullet_limit = turn_bullet_limit
	
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
	d.patience = patience
	
	d.can_players_edit = can_players_edit
	return d

static func deserialize(json_game_settings) -> GameSettings:
	var gs = GameSettings.new()
	# Getting default values here ensures presets made without this rules will still run.
	var x = json_game_settings.get("board_size_x", 8)
	var y = json_game_settings.get("board_size_y", 8)
	gs.board_size = Vector2i(x, y)
	
	gs.can_players_edit = json_game_settings.get("can_players_edit", false)
	
	gs.victory_annihilation = json_game_settings.get("victory_annihilation", true)
	gs.victory_any_sacred = json_game_settings.get("victory_any_sacred", false)
	gs.victory_all_sacred = json_game_settings.get("victory_all_sacred", false)
	gs.victory_sacred_type = json_game_settings.get("victory_sacred_type", 0)
	
	gs.turn_sequential = json_game_settings.get("turn_sequential", true)
	gs.turn_concurrent = json_game_settings.get("turn_concurrent", false)
	gs.turn_queue = json_game_settings.get("turn_queue", false)
	gs.turn_cooldown = json_game_settings.get("turn_cooldown", false)
	
	gs.turns_at_a_time = json_game_settings.get("turns_at_a_time", 1)
	gs.turn_queue_time = json_game_settings.get("turn_queue_time", 0)
	gs.turn_cooldown_time = json_game_settings.get("turn_cooldown_time", 0)
	
	gs.turn_bullet_chess = json_game_settings.get("turn_bullet_chess", false)
	gs.turn_bullet_limit = json_game_settings.get("turn_bullet_limit", 0)
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
	gs.patience = json_game_settings.get("patience", false)
	
	return gs
