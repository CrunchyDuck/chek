class_name VictoryScreenStat
extends Node

@onready
var label_name: RichTextLabel = $Name
@onready
var label_subfield: RichTextLabel = $Subfield

var stats: Player.PlayerStats
var pid: int:
	get:
		return stats.player_num
var pcol: Color:
	get:
		return ColorController.player_primary_colors[pid]

const num_misc_to_display = 2
func fill_stats(_stats: Player.PlayerStats):
	self.stats = _stats

#region Main stats
func add_killed():
	var l = label_subfield.duplicate()
	l.text = "KILLED: " + ColorController.color_text(str(stats.pieces_killed), pcol)

func add_lost():
	pass

func add_turns_taken():
	pass

func add_distance():
	pass
	
func add_average_turn():
	pass
#endregion

#region Misc stats
func add_mistakes():
	pass
	
func add_tricks():
	pass

func add_lights_on():
	pass

func add_ventilation_on():
	pass

func add_montor_off():
	pass

func add_happy():
	pass

func add_cheated():
	pass
#endregion
