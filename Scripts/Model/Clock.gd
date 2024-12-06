extends Node

@onready var hour: MeshInstance3D = $ClockPin/ClockHour
@onready var minute: MeshInstance3D = $ClockPin/ClockMinute
@onready var second: MeshInstance3D = $ClockPin/ClockSecond

func _process(delta):
	var t = Time.get_time_dict_from_system()
	
	hour.rotation_degrees.y = wrapf(float(t["hour"]), 0, 12) * -(360 / 12) + 90
	minute.rotation_degrees.y = wrapf(float(t["minute"]), 0, 60) * -(360 / 60) + 90
	second.rotation_degrees.y = wrapf(float(t["second"]), 0, 60) * -(360 / 60) + 90
