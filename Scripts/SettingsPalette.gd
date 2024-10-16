extends Control

@onready
var screen_central: Control = $"../.."
@onready
var palette_name: Label = $PaletteName
@onready
var button_previous: Button = $Previous
@onready
var button_next: Button = $Next

func _ready() -> void:
	button_previous.pressed.connect(ColorControllers.previous_palette)
	button_next.pressed.connect(ColorControllers.next_palette)

func _process(delta: float) -> void:
	palette_name.text = ColorControllers.current_palette_name
