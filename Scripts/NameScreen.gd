extends RichTextLabel

@export var game_id: int

func _ready():
  bbcode_enabled = true

func _process(delta: float) -> void:
  text = ""
  var p = GameController.players_by_game_id
  if p.has(game_id):
    text = ColorControllers.color_by_player(p[game_id].character_name, game_id)
