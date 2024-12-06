class_name ColorController
extends Node

const color_count = 8
const color_spacing = 1.0 / (color_count - 1.0)

const colors = {
	primary = Color(0, 0, 0),  # Black squares
	c1 = Color(color_spacing * 1, color_spacing * 1, color_spacing * 1), # Background color
	c2 = Color(color_spacing * 2, color_spacing * 2, color_spacing * 2),
	c3 = Color(color_spacing * 3, color_spacing * 3, color_spacing * 3),
	c4 = Color(color_spacing * 4, color_spacing * 4, color_spacing * 4),
	c5 = Color(color_spacing * 5, color_spacing * 5, color_spacing * 5),
	c6 = Color(color_spacing * 6, color_spacing * 6, color_spacing * 6), # Chat text
	secondary = Color(1, 1, 1),  # White squares
}

const player_primary_colors = [
	colors.c2,
	colors.c3,
	colors.c4,
	colors.c5,
]

const player_secondary_colors = [
	colors.c3,
	colors.c2,
	colors.c5,
	colors.c4,
]

const description_color = colors.c4

const system_message_color = colors.primary
const system_message_body_color = colors.secondary

const preset_button_selected_color = colors.c3

var current_palette: Texture2D:
	get:
		return palettes[current_palette_name]
var current_palette_name: String:
	get:
		return palettes.keys()[_current_index]
var palettes: Dictionary = {}
var palettes_primary_color: Dictionary = {}
var _current_index: int = 7  # I think this palette is the most clear.`

signal palette_updated

func _ready():
	_load_palettes()
	palette_updated.connect(_set_button_colors)
	MainScreenController.instance.next_palette_button.on_pressed.connect(next_palette)
	MainScreenController.instance.previous_palette_button.on_pressed.connect(previous_palette)
	_set_button_colors()
	
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
			palettes[parts[0]] = p
			var pixel = p.get_image().get_pixel(7, 0)
			palettes_primary_color[p] = pixel
	
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

func _set_button_colors():
	var palette = palettes.values()[wrapi(_current_index - 1, 0, palettes.size())]
	var color: Color = palettes_primary_color[palette]
	var light = MainScreenController.instance.previous_palette_power.power_to
	var nt: StandardMaterial3D = light.lit_texture.duplicate()
	nt.emission = color
	light.change_lit_texture(nt)
	
	palette = palettes.values()[wrapi(_current_index + 1, 0, palettes.size())]
	color = palettes_primary_color[palette]
	light = MainScreenController.instance.next_palette_power.power_to
	nt = light.lit_texture.duplicate()
	nt.emission = color
	light.change_lit_texture(nt)
	
func color_by_player(content: String, game_id: int):
	return color_text(content, ColorControllers.player_primary_colors[game_id])

static func color_text(content: String, color: Color):
	var my_color: String = color.to_html()
	return "[color=%s]%s[/color]" % [my_color, content]
