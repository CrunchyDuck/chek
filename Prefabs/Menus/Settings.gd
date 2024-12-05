extends Control

@onready
var button_back: Button = $Settings1/TitleBack/Back

@onready
var label_palette: Label = $Settings1/Palette/PaletteValue/PaletteName
@onready
var button_previous: Button = $Settings1/Palette/PaletteValue/Previous
@onready
var button_next: Button = $Settings1/Palette/PaletteValue/Next

func _ready() -> void:
	button_back.pressed.connect(_on_back)
	
	button_previous.pressed.connect(_on_previous_palette)
	button_next.pressed.connect(_on_next_palette)

func _process(delta: float) -> void:
	label_palette.text = ColorControllers.current_palette_name

func _on_previous_palette():
	ColorControllers.previous_palette()
	
func _on_next_palette():
	ColorControllers.next_palette()

func _on_back():
	MainScreenController.load_new_scene("Menus.Start")
