extends Node

@onready
var node_name: Label3D = $Name
@onready
var node_job: Label3D = $Job

func _ready() -> void:
	node_name.text = GameController.character_name
	node_job.text = GameController.job_name
