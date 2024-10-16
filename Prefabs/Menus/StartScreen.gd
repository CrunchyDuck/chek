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
	button_join.pressed.connect(_on_settings)

func _on_start():
	PrefabController.get_prefab("Lobby")
	queue_free()
	
func _on_join():
	queue_free()
	
func _on_settings():
	queue_free()
