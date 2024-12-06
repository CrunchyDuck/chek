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
var player:
	get:
		return GameController.players_by_game_id[pid]
var pcol: Color:
	get:
		return ColorController.player_primary_colors[pid]

const num_misc_to_display = 2

func fill_stats(_stats: Player.PlayerStats):
	self.stats = _stats
	label_name.text = ColorController.color_text(player.character_name, pcol)
	
	add_killed()
	add_lost()
	add_turns_taken()
	add_distance()
	add_average_turn()
	
	var miscs: Array[Callable] = [add_mistakes, add_tricks, add_happy, add_cheated]
	for __ in range(num_misc_to_display):
		var i = randi_range(0, miscs.size() - 1)
		var f = miscs.pop_at(i)
		f.call()
	
	remove_child(label_subfield)

#region Main stats
func add_killed():
	var l = label_subfield.duplicate()
	l.text = "KILLED: " + ColorController.color_text(str(stats.pieces_killed), pcol)
	add_child(l)

func add_lost():
	var l = label_subfield.duplicate()
	l.text = "LOST: " + ColorController.color_text(str(stats.pieces_lost), pcol)
	add_child(l)

func add_turns_taken():
	var l = label_subfield.duplicate()
	l.text = "TURNS: " + ColorController.color_text(str(stats.turns_taken), pcol)
	add_child(l)

func add_distance():
	var l = label_subfield.duplicate()
	l.text = "MOVED: " + ColorController.color_text(str(stats.distance_moved), pcol)
	add_child(l)
	
func add_average_turn():
	var l = label_subfield.duplicate()
	l.text = "AVG TRN TIME: " + ColorController.color_text(str(stats.average_turn_time), pcol)
	add_child(l)
#endregion

#region Misc stats
func add_mistakes():
	var l = label_subfield.duplicate()
	l.text = "MISTAKES: " + ColorController.color_text(str(stats.mistakes), pcol)
	add_child(l)
	
func add_tricks():
	var l = label_subfield.duplicate()
	l.text = "TRICKS: " + ColorController.color_text(str(stats.tricks_pulled), pcol)
	add_child(l)

#func add_lights_on():
	#var l = label_subfield.duplicate()
	#l.text = "HAD LIGHT ON: " + ColorController.color_text(str(stats.lights_on), pcol)
	#add_child(l)
#
#func add_ventilation_on():
	#var l = label_subfield.duplicate()
	#l.text = "HAD VENT ON: " + ColorController.color_text(str(stats.ventilation_on), pcol)
	#add_child(l)
#
#func add_monitor_off():
	#var l = label_subfield.duplicate()
	#l.text = "TRNED OFF MONITOR: " + ColorController.color_text(str(stats.times_turned_monitor_off), pcol)
	#add_child(l)

func add_happy():
	var l = label_subfield.duplicate()
	l.text = "HAPPY: " + ColorController.color_text(str(stats.happy), pcol)
	add_child(l)

func add_cheated():
	var l = label_subfield.duplicate()
	l.text = "CHEATED: " + ColorController.color_text(str(stats.cheated), pcol)
	add_child(l)
#endregion
