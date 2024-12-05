class_name SetupMenu
extends Control

var settings: BoardBase.GameSettings:
	get:
		return GameController.game_settings
	set(value):
		GameController.game_settings = value

@onready
var button_divine_wind: CheckBox = $DivineWind/CheckBox
@onready
var button_no_retreat: CheckBox = $NoRetreat/CheckBox

@onready
var button_victory_annihilation: CheckBox = $Annihilation/CheckBox
@onready
var button_victory_all_sacred: CheckBox = $VCSacred/SacredFields/AllSacredPiece/CheckBox
@onready
var button_victory_any_sacred: CheckBox = $VCSacred/SacredFields/AnySacredPiece/CheckBox
@onready
var button_sacred_piece: SacredPieceSelector = $VCSacred/SacredFields/AnySacredPiece/PieceType

func _ready() -> void:
	button_victory_all_sacred.pressed.connect(func (): _set_victory_condition(button_victory_all_sacred))
	button_victory_any_sacred.pressed.connect(func (): _set_victory_condition(button_victory_any_sacred))
	button_victory_annihilation.pressed.connect(func (): _set_victory_condition(button_victory_annihilation))
	button_divine_wind.pressed.connect(_on_change)
	button_no_retreat.pressed.connect(_on_change)
	settings = gather_settings()
	_set_victory_condition(button_victory_annihilation)

func _set_victory_condition(new_condition: CheckBox):
	# Flick off all but the new condition
	button_victory_all_sacred.set_pressed_no_signal(false)
	button_victory_any_sacred.set_pressed_no_signal(false)
	button_victory_annihilation.set_pressed_no_signal(false)
	
	new_condition.set_pressed_no_signal(true)
	_on_change()

func _on_change():
	load_settings.rpc(gather_settings().serialize())
	
func gather_settings() -> BoardBase.GameSettings:
	var settings = BoardBase.GameSettings.new()
	settings.victory_annihilation = button_victory_annihilation.button_pressed
	settings.victory_lose_all_sacred = button_victory_all_sacred.button_pressed
	settings.victory_lose_any_sacred = button_victory_any_sacred.button_pressed
	settings.victory_sacred_type = button_sacred_piece.current_piece
	
	settings.divine_wind = button_divine_wind.button_pressed
	settings.no_retreat = button_no_retreat.button_pressed
	return settings

# TODO: Stop peers clicking buttons unless allowed
func update_buttons_clickable():
	pass
	#var state = false
	#if multiplayer.is_server():
		#state = true
	#else:
		#state = GameController.game_settings.can_players_edit
		#
	#for button in buttons.values():
		#button.disabled = !state

@rpc("authority", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
	settings = BoardBase.GameSettings.deserialize(json_settings)
	button_divine_wind.button_pressed = settings.divine_wind
	button_no_retreat.button_pressed = settings.no_retreat
	
	button_victory_any_sacred.button_pressed = settings.victory_lose_any_sacred
	button_victory_all_sacred.button_pressed = settings.victory_lose_all_sacred
	button_victory_annihilation.button_pressed = settings.victory_annihilation
	button_sacred_piece.current_piece = settings.victory_sacred_type
	button_sacred_piece._set_texture(settings.victory_sacred_type)
	
