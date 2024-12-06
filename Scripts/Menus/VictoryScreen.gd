class_name VictoryScreen
extends Node

static var instance = null

@onready
var button_return: Button = $Button
@onready
var label_winner: RichTextLabel = $CenterContainer/VBoxContainer/Winner
@onready
var grid_stats: GridContainer = $CenterContainer/VBoxContainer/PlayerStats

func _ready() -> void:
	button_return.pressed.connect(_on_return)
	label_winner.bbcode_enabled = true
	instance = self
	for p in Player.players:
		if p.received_stats != null:
			display_stat(p.received_stats)

func _on_return():
	MainScreenController.load_new_scene("Menus.Setup.Main")

func display_victor(victor: int):
	label_winner.text = ColorController.color_text("VICTORY " + GameController.players_by_game_id[victor].character_name, ColorController.player_primary_colors[victor])

# This being done locally on each client means what stats are visible will be different for each.
# This is fine for now. Maybe fix later.
func display_stat(player_stat: Player.PlayerStats):
	var vss = PrefabController.get_prefab("Menus.VictoryScreenStat")
	var stat: VictoryScreenStat = vss.instantiate()
	grid_stats.add_child(stat)
	stat.fill_stats(player_stat)
