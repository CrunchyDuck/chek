extends Node

@onready
var button_return: Button = $CenterContainer/VBoxContainer/Button
@onready
var label_winner: RichTextLabel = $CenterContainer/VBoxContainer/Winner
@onready
var grid_stats: GridContainer = $CenterContainer/VBoxContainer/PlayerStats

func _ready() -> void:
	button_return.pressed.connect(_on_return)
	
func _on_return():
	pass

# TODO: Victory condition checking and call this
func display_stats(victor: int, player_stats: Array[Player.PlayerStats]):
	label_winner.text = ColorController.color_text("VICTORY " + GameController.players_by_game_id[victor], ColorController.player_primary_colors[victor])
	
	var vss = PrefabController.get_prefab("Menus.VictoryScreenStat")
	for p in player_stats:
		var stat: VictoryScreenStat = vss.instantiate()
		stat.fill_stats(p)
		grid_stats.add_child(stat)
