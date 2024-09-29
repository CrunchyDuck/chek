class_name Board
extends Node2D

var prefab_board_cell = preload("res://Prefabs/Board/BoardCell.tscn")
var size: Vector2i = Vector2i(8, 8)
const cell_size : Vector2i = Vector2i(64, 64)
var cells = []  # x/y 2D array

func Init(size: Vector2i):
  # Create cells
  for x in size.x:
    var row = []
    for y in size.y:
      var board_cell = prefab_board_cell.instantiate()
      board_cell.Init(self, Vector2i(x, y))
      row.append(board_cell)
      add_child(board_cell)
      

func _ready() -> void:
  LoadBoard()

func LoadBoard():
  for x in size.x:
    for y in size.y:
      var sprite_object = Sprite2D.new()
      var sprite_path
      if (x + y) % 2 == 0:
        sprite_path = "res://Sprites/Board/WhiteTile.png"
      else:
        sprite_path = "res://Sprites/Board/BlackTile.png"
      sprite_object.texture = load(sprite_path)
      sprite_object.position = self.GridToPosition(x, y)
      sprite_object.centered = false
      self.add_child(sprite_object)

func GridToPosition(x: int, y: int) -> Vector2:
  var pos: Vector2 = self.position
  pos.x += x * cell_size.x
  pos.y += y * cell_size.y
  return pos
