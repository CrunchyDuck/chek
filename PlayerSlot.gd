class_name PlayerSlot
extends Control

var ai_sprite = load("res://Sprites/AIPlayer.png")
var player_sprite = load("res://Sprites/Player.png")
var sprite_positive = load("res://Sprites/PositiveLight.png")
var sprite_negative = load("res://Sprites/NegativeLight.png")

@onready var node_player_type = $HBoxContainer/PlayerType
@onready var node_can_move = $HBoxContainer/VBoxContainer/CanMove
@onready var node_name = $HBoxContainer/Name
var assigned_player: Player


func _process(delta: float) -> void:
	if assigned_player == null:
		node_player_type.texture = null
		node_name.text = ""
		node_can_move.texture = null
		return
	
	node_player_type.texture = player_sprite
	if assigned_player is AIPlayer:
		node_player_type.texture = ai_sprite
		
	node_name.text = assigned_player.name
	
	node_can_move.texture = sprite_negative
	if assigned_player.can_move:
		node_can_move.texture = sprite_positive
	
