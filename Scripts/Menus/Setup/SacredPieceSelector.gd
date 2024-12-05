class_name SacredPieceSelector
extends TextureButton

var current_piece: ChessPiece.ePieces = ChessPiece.ePieces.King

func _ready():
	pressed.connect(next_piece)
	_set_texture(current_piece)

func next_piece():
	current_piece = wrapi(current_piece + 1, 0, ChessPiece.ePieces.size()) as ChessPiece.ePieces
	if current_piece == ChessPiece.ePieces.Blocker:
		next_piece()
		return
	
	_set_texture(current_piece)

func _set_texture(piece_type: ChessPiece.ePieces):
	var p = PrefabController.get_prefab(ChessPiece.piece_prefabs[piece_type]).instantiate()
	var texture = p.node_sprite.texture
	texture_normal = texture
	texture_focused = texture
	texture_hover = texture
	texture_disabled = texture
	texture_pressed = texture
