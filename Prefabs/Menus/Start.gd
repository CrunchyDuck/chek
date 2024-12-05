extends Control

@onready
var button_start: Button = $VBoxContainer/Start
@onready
var button_join: Button = $VBoxContainer/Join
@onready
var button_settings: Button = $VBoxContainer/Settings

func _ready() -> void:
	button_start.pressed.connect(_on_start)
	button_join.pressed.connect(_on_join)
	button_settings.pressed.connect(_on_settings)

func _on_start():
	MainScreenController.load_new_scene("Menus.LobbyHosting")
	
func _on_join():
	MainScreenController.load_new_scene("Menus.LobbyJoining")
	
func _on_settings():\
	MainScreenController.load_new_scene("Menus.Settings")
