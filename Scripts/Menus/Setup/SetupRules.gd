class_name SetupRules
extends Control

# TODO: Make checkboxes use a different colour when disable, so they're not invisible.
var settings: BoardBase.GameSettings:
	get:
		return GameController.game_settings
	set(value):
		GameController.game_settings = value

@onready
var button_can_players_edit: CheckBox = $CanPlayersEdit/CheckBox

@onready
var button_divine_wind: CheckBox = $DivineWind/CheckBox
@onready
var button_no_retreat: CheckBox = $NoRetreat/CheckBox
@onready
var button_formation_broken: CheckBox = $FormationBroken/CheckBox

@onready
var button_victory_annihilation: CheckBox = $Annihilation/CheckBox
@onready
var button_victory_all_sacred: CheckBox = $VCSacred/SacredFields/AllSacredPiece/CheckBox
@onready
var button_victory_any_sacred: CheckBox = $VCSacred/SacredFields/AnySacredPiece/CheckBox
@onready
var button_sacred_piece: SacredPieceSelector = $VCSacred/SacredFields/AnySacredPiece/PieceType

@onready
# This excludes the setting for if players can modify the game state
var rules_buttons: Array[BaseButton] = [
	button_divine_wind,
	button_no_retreat,
	button_victory_annihilation,
	button_victory_all_sacred,
	button_victory_any_sacred,
	button_sacred_piece,
	button_formation_broken,
]

func _ready() -> void:
	button_can_players_edit.pressed.connect(_on_change)
	button_victory_all_sacred.pressed.connect(func (): _set_victory_condition(button_victory_all_sacred))
	button_victory_any_sacred.pressed.connect(func (): _set_victory_condition(button_victory_any_sacred))
	button_victory_annihilation.pressed.connect(func (): _set_victory_condition(button_victory_annihilation))
	
	button_divine_wind.pressed.connect(_on_change)
	button_no_retreat.pressed.connect(_on_change)
	button_formation_broken.pressed.connect(_on_change)
	
	settings = gather_settings()
	_set_victory_condition(button_victory_annihilation)
	
	if multiplayer.is_server():
		update_buttons_clickable(true)
	else:
		update_buttons_clickable(false)
		request_load_settings.rpc_id(1)

func _set_victory_condition(new_condition: CheckBox):
	# Flick off all but the new condition
	button_victory_all_sacred.set_pressed_no_signal(false)
	button_victory_any_sacred.set_pressed_no_signal(false)
	button_victory_annihilation.set_pressed_no_signal(false)
	
	new_condition.set_pressed_no_signal(true)
	_on_change()

func _on_change():
	settings = gather_settings()
	if multiplayer.is_server():
		load_settings.rpc(settings.serialize())
	elif settings.can_players_edit:
		client_load_settings.rpc_id(1, settings.serialize())
	
func gather_settings() -> BoardBase.GameSettings:
	var settings = BoardBase.GameSettings.new()
	settings.can_players_edit = button_can_players_edit.button_pressed
	
	settings.victory_annihilation = button_victory_annihilation.button_pressed
	settings.victory_lose_all_sacred = button_victory_all_sacred.button_pressed
	settings.victory_lose_any_sacred = button_victory_any_sacred.button_pressed
	settings.victory_sacred_type = button_sacred_piece.current_piece
	
	settings.divine_wind = button_divine_wind.button_pressed
	settings.no_retreat = button_no_retreat.button_pressed
	settings.formation_broken = button_formation_broken.button_pressed
	return settings

func update_buttons_clickable(clickable: bool):
	if multiplayer.is_server():
		button_can_players_edit.disabled = false
	else:
		button_can_players_edit.disabled = true
	
	for button in rules_buttons:
		button.disabled = !clickable

@rpc("authority", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
	settings = BoardBase.GameSettings.deserialize(json_settings)
	button_can_players_edit.set_pressed_no_signal(settings.can_players_edit)
	button_divine_wind.set_pressed_no_signal(settings.divine_wind)
	button_no_retreat.set_pressed_no_signal(settings.no_retreat)
	
	button_victory_any_sacred.set_pressed_no_signal(settings.victory_lose_any_sacred)
	button_victory_all_sacred.set_pressed_no_signal(settings.victory_lose_all_sacred)
	button_victory_annihilation.set_pressed_no_signal(settings.victory_annihilation)
	button_sacred_piece.current_piece = settings.victory_sacred_type
	button_sacred_piece._set_texture(settings.victory_sacred_type)
	
	if not multiplayer.is_server():
		update_buttons_clickable(settings.can_players_edit)
	
@rpc("any_peer", "call_local", "reliable")
func client_load_settings(json_settings: Dictionary):
	if not multiplayer.is_server():
		return
	if not settings.can_players_edit:
		return
	load_settings.rpc(json_settings)

@rpc("any_peer", "call_remote", "reliable")
func request_load_settings():
	if not multiplayer.is_server():
		return
	load_settings.rpc_id(multiplayer.get_remote_sender_id(), settings.serialize())
