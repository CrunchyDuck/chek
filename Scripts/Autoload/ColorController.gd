class_name ColorController
extends Node

const color_count = 8
const color_spacing = 1.0 / (color_count - 1.0)

const colors = {
  primary = Color(0, 0, 0), # P1
  secondary = Color(1, 1, 1), # P2
  c1 = Color(color_spacing * 1, color_spacing * 1, color_spacing * 1),
  c2 = Color(color_spacing * 2, color_spacing * 2, color_spacing * 2), # Background color
  c3 = Color(color_spacing * 3, color_spacing * 3, color_spacing * 3), # P3
  c4 = Color(color_spacing * 4, color_spacing * 4, color_spacing * 4), # P4
  c5 = Color(color_spacing * 5, color_spacing * 5, color_spacing * 5),
  c6 = Color(color_spacing * 6, color_spacing * 6, color_spacing * 6), # Chat text
}

const player_colors = [
  colors.secondary,
  colors.primary,
  colors.c3,
  colors.c4,
]

var current_palette: CompressedTexture2D:
  get:
    return palettes[current_palette_name]
var current_palette_name: String:
  get:
    return palettes.keys()[_current_index]
var palettes: Dictionary = {}
var _current_index: int = 0

signal palette_updated

func _ready():
  _load_palettes()
  
func _input(event):
  if event.is_action_pressed("PreviousPalette"):
    previous_palette()
  elif event.is_action_pressed("NextPalette"):
    next_palette()

func _load_palettes():
  palettes = {}
  var dir = DirAccess.open("res://Sprites/Palettes/")
  var files := dir.get_files()
  for file in files:
    var parts = file.split(".")
    if parts[-1] == "png":
      var p = load(dir.get_current_dir() + "/" + file)
      palettes[parts[0]] = load(dir.get_current_dir() + "/" + file)
  
  palette_updated.emit()

func previous_palette():
  _current_index -= 1
  _current_index = wrapi(_current_index, 0, palettes.size())
  palette_updated.emit()
  
func next_palette():
  _current_index += 1
  _current_index = wrapi(_current_index, 0, palettes.size())
  palette_updated.emit()
  pass
  
func color_by_player(content: String, game_id: int):
  var my_color: String = ColorControllers.player_colors[game_id].to_html()
  return "[color=%s]%s[/color]" % [my_color, content]
