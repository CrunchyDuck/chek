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
	"victory_annihilation" = $Annihilation/CheckBox,
	"victory_all_sacred" = $VCSacred/SacredFields/AllSacredPiece/CheckBox,
	"victory_any_sacred" = $VCSacred/SacredFields/AnySacredPiece/CheckBox,
}

@onready
var modifier_buttons: Dictionary = {
	"divine_wind" = $DivineWind/CheckBox,
	"no_retreat" = $NoRetreat/CheckBox,
	"formation_broken" = $FormationBroken/CheckBox,
	"b_team" = $BTeam/CheckBox,
	"round_earth" = $RoundEarth/CheckBox,
	"polar_crossing" = $PolarCrossing/CheckBox,
	"no_gods" = $NoGods/CheckBox,
	"greater_good" = $GreaterGood/CheckBox,
	"foreign_ground" = $ForeignGround/CheckBox,
	"brave_and_stupid" = $BraveAndStupid/CheckBox,
}

func _ready() -> void:
	button_can_players_edit.pressed.connect(_on_change)
	
	vc_buttons.victory_all_sacred.pressed.connect(func (): _set_victory_condition(vc_buttons.victory_all_sacred))
	vc_buttons.victory_any_sacred.pressed.connect(func (): _set_victory_condition(vc_buttons.victory_any_sacred))
	vc_buttons.victory_annihilation.pressed.connect(func (): _set_victory_condition(vc_buttons.victory_annihilation))
	
	for b in modifier_buttons.values():
		b.pressed.connect(_on_change)
		
	settings = gather_settings()
	_set_victory_condition(vc_buttons.victory_annihilation)
	
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
	var settings = {}
	settings.can_players_edit = button_can_players_edit.button_pressed
	
	for b in vc_buttons.keys():
		settings[b] = vc_buttons[b].button_pressed
	for b in modifier_buttons.keys():
		settings[b] = modifier_buttons[b].button_pressed
	
	settings.victory_sacred_type = button_sacred_piece.current_piece
	return BoardBase.GameSettings.deserialize(settings)

func update_buttons_clickable(clickable: bool):
	if multiplayer.is_server():
		button_can_players_edit.disabled = false
	else:
		button_can_players_edit.disabled = true
	
	for button in modifier_buttons.values():
		button.disabled = !clickable
		
	for button in vc_buttons.values():
		button.disabled = !clickable

@rpc("authority", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
	button_can_players_edit.set_pressed_no_signal(json_settings.can_players_edit)
	for k in modifier_buttons.keys():
		modifier_buttons[k].set_pressed_no_signal(json_settings[k])
	
	for k in vc_buttons.keys():
		vc_buttons[k].set_pressed_no_signal(json_settings[k])
	
	button_sacred_piece.current_piece = json_settings.victory_sacred_type
	button_sacred_piece._set_texture(json_settings.victory_sacred_type)
	
	if not multiplayer.is_server():
		update_buttons_clickable(json_settings.can_players_edit)
	settings = BoardBase.GameSettings.deserialize(json_settings)
	
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
