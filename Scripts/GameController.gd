class_name GameController
extends Node

var prefab_player: PackedScene = preload("res://Prefabs/Player.tscn")
var prefab_pawn: PackedScene = preload("res://Prefabs/Pieces/Pawn.tscn")
var prefab_board: PackedScene = preload("res://Prefabs/Board/Board.tscn")
var prefab_board_cell: PackedScene = preload("res://Prefabs/Board/BoardCell.tscn")

var board: Board
var board_size: Vector2i = Vector2i(8, 8)

func _ready():
  start_game()

func start_game():
  var p1 = prefab_player.instantiate()
  var p2 = prefab_player.instantiate()
  add_child(p1)
  add_child(p2)
  var players = [p1, p2]
  
  var grid = create_grid(board_size)
  spawn_piece(prefab_pawn, grid[4][3], ChessPiece.Orientation.West, players[0])
  spawn_piece(prefab_pawn, grid[3][2], ChessPiece.Orientation.East, players[0])
  board = prefab_board.instantiate()
  add_child(board)
  board.Init(grid)

func create_grid(grid_size: Vector2i) -> Array:
  var cells = []
  for y in board_size.y:
    var row = []
    for x in board_size.x:
      var board_cell = prefab_board_cell.instantiate()
      row.append(board_cell)
    cells.append(row)
  return cells
  
func spawn_piece(piece_prefab: PackedScene, cell: BoardCell, orientation: ChessPiece.Orientation, owned_by: Player) -> ChessPiece:
  var piece = prefab_pawn.instantiate()
  cell.occupying_piece = piece
  piece.Init(cell, orientation, owned_by)
  return piece
