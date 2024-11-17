class_name BoardBase
extends Control

var grid_size: Vector2i:
  get:
    var y = grid.size()
    if y == 0:
      return Vector2i(0, 0)
    var x = grid[0].size()
    return Vector2i(x, y)
const cell_size : Vector2i = Vector2i(64, 64)
var bounds: Vector2:
  get:
    return grid_size * cell_size
var grid: Array[Array] = []  # x/y 2D array
var board_size: Vector2:
  get:
    return Vector2(grid_size * cell_size)

var game_settings: GameController.GameSettings:
  get:
    return GameController.game_settings

var node_cells: Control:
  get:
    return $Cells
var node_pieces: Control:
  get:
    return $Pieces
    
var pieces_by_game_id: Dictionary:
  get:
    var _players = {}
    for _p in node_pieces.get_children():
      var _pid = _p.player
      # Create players up to the ID needed.
      for _id in range(_players.size(), _pid + 1):
        _players[_id] = []
      _players[_pid].append(_p)
    return _players

func create_new_grid(_grid_size: Vector2i) -> Array[Array]:
  for n in node_cells.get_children():
    n.queue_free()

  node_cells.position = Vector2(cell_size) / 2
  node_pieces.position = Vector2(cell_size) / 2
  grid = []
  for y in _grid_size.y:
    var row = []
    for x in _grid_size.x:
      var board_cell: BoardCell = PrefabController.get_prefab("Board.BoardCell").instantiate()
      board_cell.cell_coordinates = Vector2i(x, y)
      board_cell.board = self
      node_cells.add_child(board_cell)
      board_cell.position = cell_to_position(Vector2i(x, y))
      row.append(board_cell)
    grid.append(row)
  return grid

func clear_pieces():
  for n in node_pieces.get_children():
    n.queue_free()

#region Cell selection
func grid_to_position(x: int, y: int) -> Vector2:
  var pos: Vector2
  pos.x += x * cell_size.x
  pos.y += y * cell_size.y
  return pos

func cell_to_position(cell: Vector2i) -> Vector2:
  return cell * cell_size

func position_to_cell(pos: Vector2) -> BoardCell:
  # Relative to our position
  # TODO: When I implement the 3D console, this will need to be changed.
  pos -= global_position
  if pos.x < 0 or pos.y < 0 or pos.x > bounds.x or pos.y > bounds.x:
    return null
  var x = int(pos.x) / cell_size.x
  var y = int(pos.y) / cell_size.y
  
  return grid[y][x]

func get_cell(pos: Vector2i) -> BoardCell:
  #if game_settings.wrapx:
  pos.x = wrapi(pos.x, 0, grid_size.x - 1)
  pos.y = wrapi(pos.y, 0, grid_size.y - 1)
  
  if not is_coordinate_in_bounds(pos):
    return null
  
  return grid[pos.y][pos.x]

func is_coordinate_in_bounds(coordinate: Vector2i) -> bool:
  var x = coordinate.x
  var y = coordinate.y
  return x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y
#endregion

# TODO: (de)Serialize board
func serialize() -> GameController.BoardState:
  var bs = GameController.BoardState.new(board_size)
  var players = []
  for piece in node_pieces.get_children():
    var p = piece.serialize()
    # Create players up to the ID needed.
    for id in range(players.size(), p.player + 1):
      players.append(GameController.PlayerState.new(id))
    players[p.player].pieces.append(p)
  
  bs.players = players
  return bs

func load_state(state: GameController.BoardState):
  clear_pieces()
  create_new_grid(state.size)

func _position_board():
  var new_position = get_viewport_rect().size / 2
  new_position -= board_size / 2
  position = new_position
