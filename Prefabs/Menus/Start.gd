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
	$"..".add_child(PrefabController.get_prefab("Menus.LobbyHosting").instantiate())
	Helpers.destroy_node(self)
	
func _on_join():
	$"..".add_child(PrefabController.get_prefab("Menus.LobbyJoining").instantiate())
	Helpers.destroy_node(self)
	
func _on_settings():
	$"..".add_child(PrefabController.get_prefab("Menus.Settings").instantiate())
	Helpers.destroy_node(self)
