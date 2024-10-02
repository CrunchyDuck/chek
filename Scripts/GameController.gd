class_name GameController
extends Node

var prefab_pawn: PackedScene = preload("res://Prefabs/Pieces/Pawn.tscn")
var prefab_queen: PackedScene = preload("res://Prefabs/Pieces/Queen.tscn")
var prefab_king: PackedScene = preload("res://Prefabs/Pieces/King.tscn")
var prefab_rook: PackedScene = preload("res://Prefabs/Pieces/Rook.tscn")
var prefab_knight: PackedScene = preload("res://Prefabs/Pieces/Knight.tscn")
var prefab_bishop: PackedScene = preload("res://Prefabs/Pieces/Bishop.tscn")
var prefab_board: PackedScene = preload("res://Prefabs/Board/Board.tscn")
var prefab_board_cell: PackedScene = preload("res://Prefabs/Board/BoardCell.tscn")

var board: Board

func _ready():
  start_game()

func start_game():
  var p1 = Player.new(PlayerID.Player1)
  var p2 = Player.new(PlayerID.Player2)
  var players = [p1, p2]
  
  load_board_state(standard_board_setup(), players)

func load_board_state(state: BoardState, players: Array):
  if players.size() != state.players.size():
    print("Incorrect number of players for board state!")
    return
  
  var grid = create_grid(state.size)
  for i in state.players.size():
    var player: Player = players[i]
    var player_state: PlayerState = state.players[i]
    for piece in player_state.pieces:
      spawn_piece(piece.type, grid[piece.position.y][piece.position.x], piece.orientation, player)
  board = prefab_board.instantiate()
  add_child(board)
  board.Init(grid)

func standard_board_setup() -> BoardState:
  var board = BoardState.new(Vector2i(8, 8))
  var p1 = PlayerState.new()
  var p2 = PlayerState.new()
  
  p1.add_piece(prefab_pawn, Vector2i(0, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(1, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(2, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(3, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(4, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(5, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(6, 1), ChessPiece.Orientation.South)
  p1.add_piece(prefab_pawn, Vector2i(7, 1), ChessPiece.Orientation.South)
  
  p1.add_piece(prefab_queen, Vector2i(3, 0), ChessPiece.Orientation.South)
  p1.add_piece(prefab_king, Vector2i(4, 0), ChessPiece.Orientation.South)
  
  p1.add_piece(prefab_rook, Vector2i(0, 0), ChessPiece.Orientation.South)
  p1.add_piece(prefab_rook, Vector2i(7, 0), ChessPiece.Orientation.South)
  p1.add_piece(prefab_knight, Vector2i(1, 0), ChessPiece.Orientation.South)
  p1.add_piece(prefab_knight, Vector2i(6, 0), ChessPiece.Orientation.South)
  p1.add_piece(prefab_bishop, Vector2i(2, 0), ChessPiece.Orientation.South)
  p1.add_piece(prefab_bishop, Vector2i(5, 0), ChessPiece.Orientation.South)
  board.players.append(p1)
  
  p2.add_piece(prefab_pawn, Vector2i(0, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(1, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(2, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(3, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(4, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(5, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(6, 6), ChessPiece.Orientation.North)
  p2.add_piece(prefab_pawn, Vector2i(7, 6), ChessPiece.Orientation.North)
  
  p2.add_piece(prefab_queen, Vector2i(3, 7), ChessPiece.Orientation.North)
  p2.add_piece(prefab_king, Vector2i(4, 7), ChessPiece.Orientation.North)
  
  p2.add_piece(prefab_rook, Vector2i(0, 7), ChessPiece.Orientation.North)
  p2.add_piece(prefab_rook, Vector2i(7, 7), ChessPiece.Orientation.North)
  p2.add_piece(prefab_knight, Vector2i(1, 7), ChessPiece.Orientation.North)
  p2.add_piece(prefab_knight, Vector2i(6, 7), ChessPiece.Orientation.North)
  p2.add_piece(prefab_bishop, Vector2i(2, 7), ChessPiece.Orientation.North)
  p2.add_piece(prefab_bishop, Vector2i(5, 7), ChessPiece.Orientation.North)
  board.players.append(p2)
  
  return board

func create_grid(grid_size: Vector2i) -> Array:
  var cells = []
  for y in grid_size.y:
    var row = []
    for x in grid_size.x:
      var board_cell = prefab_board_cell.instantiate()
      row.append(board_cell)
    cells.append(row)
  return cells
  
func spawn_piece(piece_prefab: PackedScene, cell: BoardCell, orientation: ChessPiece.Orientation, owned_by: Player) -> ChessPiece:
  var piece = piece_prefab.instantiate()
  cell.occupying_piece = piece
  piece.Init(cell, orientation, owned_by)
  return piece

class BoardState:
  var size: Vector2i
  var players: Array
  
  func _init(size: Vector2i):
    self.size = size
  
class PlayerState:
  var pieces: Array = []
  
  func add_piece(piece: PackedScene, position: Vector2i, orientation: ChessPiece.Orientation):
    pieces.append(PieceState.new(piece, position, orientation))

class PieceState:
  var type: PackedScene
  var position: Vector2i
  var orientation: ChessPiece.Orientation
  
  func _init(type: PackedScene, position: Vector2i, orientation: ChessPiece.Orientation):
    self.type = type
    self.position = position
    self.orientation = orientation
  
class Player:
  var id: PlayerID
  var friendly = [self]
  var init_state: PlayerState
  
  func _init(id: PlayerID):
    self.id = id
  
enum PlayerID {
  Player1,
  Player2,
  Player3,
  Player4,
}
