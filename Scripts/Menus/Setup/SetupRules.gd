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
var button_sacred_piece = $VCSacred/SacredFields/AnySacredPiece/PieceType

@onready
var vc_buttons: Dictionary = {
	"button_victory_annihilation" = $Annihilation/CheckBox,
	"button_victory_all_sacred" = $VCSacred/SacredFields/AllSacredPiece/Checkbox,
	"button_victory_any_sacred" = $VCSacred/SacredFields/AnySacredPiece/Checkbox,
}

@onready
var modifier_buttons: Dictionary = {
	"button_divine_wind" = $DivineWind/CheckBox,
	"button_no_retreat" = $NoRetreat/CheckBox,
	"button_formation_broken" = $FormationBroke /CheckBox,
	"button_b_team" = $BTeam/CheckBox,
}

func _ready() -> void:
	button_can_players_edit.pressed.connect(_on_change)
	
	vc_buttons.button_victory_all_sacred.pressed.connect(func (): _set_victory_condition(vc_buttons.button_victory_all_sacred))
	vc_buttons.button_victory_any_sacred.pressed.connect(func (): _set_victory_condition(vc_buttons.button_victory_any_sacred))
	vc_buttons.button_victory_annihilation.pressed.connect(func (): _set_victory_condition(vc_buttons.button_victory_annihilation))
	
	for b in modifier_buttons.values():
		b.pressed.connect(_on_change)
		
	settings = gather_settings()
	_set_victory_condition(vc_buttons.button_victory_annihilation)
	
	if multiplayer.is_server():
		update_buttons_clickable(true)
	else:
		update_buttons_clickable(false)
		request_load_settings.rpc_id(1)

func _set_victory_condition(new_condition: CheckBox):
	# Flick off all but the new condition
	for b in vc_buttons.values():
		b.set_pressed_no_signal(false)
	
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
	
	settings.victory_annihilation = vc_buttons.button_victory_annihilation.button_pressed
	settings.victory_lose_all_sacred = vc_buttons.button_victory_all_sacred.button_pressed
	settings.victory_lose_any_sacred = vc_buttons.button_victory_any_sacred.button_pressed
	settings.victory_sacred_type = vc_buttons.button_sacred_piece.current_piece
	
	settings.divine_wind = modifier_buttons.button_divine_wind.button_pressed
	settings.no_retreat = modifier_buttons.button_no_retreat.button_pressed
	settings.formation_broken = modifier_buttons.button_formation_broken.button_pressed
	settings.b_team = modifier_buttons.button_b_team.button_pressed
	return settings

func update_buttons_clickable(clickable: bool):
	if multiplayer.is_server():
		button_can_players_edit.disabled = false
	else:
		button_can_players_edit.disabled = true
	
	for button in modifier_buttons:
		button.disabled = !clickable
		
	for button in vc_buttons:
		button.disabled = !clickable

@rpc("authority", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
	settings = BoardBase.GameSettings.deserialize(json_settings)
	button_can_players_edit.set_pressed_no_signal(settings.can_players_edit)
	for k in modifier_buttons.keys():
		modifier_buttons[k].set_pressed_no_signal(settings[k])
	
	for k in vc_buttons.keys():
		vc_buttons[k].set_pressed_no_signal(settings[k])
	
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
