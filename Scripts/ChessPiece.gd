class_name ChessPiece
extends Node2D

# TODO: Team. Was going to do this by getting a parent, but that's discouraged in GD.
var pos: Vector2i
var move_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Bit of a mouthful - This lets us rotate vectors to be from the perspective of its team.
# y = 1 for the top of the board (Black, in a normal game), will be y = -1 relative to their facing.
func _rotate_vector_relative_to_travel_direction(vec: Vector2i) -> Vector2i:
	# TODO: Implementation.
	return vec

# Abstract base functions
func _move(to: BoardCell) -> void:
	pass
	
func _can_attack(attack_pos: BoardCell) -> bool:
	if attack_pos.occupying_piece == null:
		return false
	return false
	
func _can_move(move_pos: BoardCell) -> bool:
	if move_pos.occupying_piece != null:
		return false
	return false

func _on_kill() -> void:
	pass
	
func _on_killed() -> void:
	pass
