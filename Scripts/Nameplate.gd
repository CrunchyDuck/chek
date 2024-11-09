extends Node

@onready
var node_name: Label3D = $Name
@onready
var node_job: Label3D = $Job

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  node_name.text = GameController.character_name
  node_job.text = GameController.job_name
