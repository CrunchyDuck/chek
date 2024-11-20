class_name SetupMenu
extends Control

var settings: BoardBase.GameSettings:
  get:
    return GameController.game_settings
  set(value):
    GameController.game_settings = value

@onready
var button_start: Button = $Start
@onready
var button_divine_wind: CheckBox = $Settings/DivineWind/CheckBox
@onready
var button_no_retreat: CheckBox = $Settings/NoRetreat/CheckBox

@onready
var button_next_screen: ScreenButton = $/root/MainScene/Console/front_panel/arrow_right

func _ready() -> void:
  button_start.pressed.connect(_on_start)
  if not multiplayer.is_server():
    button_start.disabled = true
  
  button_divine_wind.pressed.connect(_on_change)
  button_no_retreat.pressed.connect(_on_change)
  settings = gather_settings()
  button_next_screen.on_pressed.connect(_next_screen)

func _next_screen(button) -> void:
  print("here")
  # Move to board setup

func _on_change():
  load_settings.rpc(gather_settings().serialize())
  
func _on_start():
  settings = gather_settings()
  
  var jgs = settings.serialize()
  var jbs = GameController.standard_board_setup().serialize()
  GameController.start_game.rpc(jgs, jbs)
  
func gather_settings() -> BoardBase.GameSettings:
  var settings = BoardBase.GameSettings.new()
  settings.divine_wind = button_divine_wind.button_pressed
  settings.no_retreat = button_no_retreat.button_pressed
  return settings

@rpc("any_peer", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
  settings = BoardBase.GameSettings.deserialize(json_settings)
  button_divine_wind.button_pressed = settings.divine_wind
  button_no_retreat.button_pressed = settings.no_retreat
  
