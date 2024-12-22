class_name SetupRules
extends Control

# TODO: Make checkboxes clickable anywhere on their line
# TODO: Make checkboxes use a different colour when disable, so they're not invisible.
var settings: GameSettings:
	get:
		return GameController.game_settings
	set(value):
		GameController.game_settings = value

var node_rule_info: Control = null

@onready
var button_can_players_edit: CheckBox = $CanPlayersEdit/CheckBox
@onready
var button_sacred_piece = $VCSacred/SacredFields/AnySacredPiece/PieceType

@onready
var turn_rule_selectors: Dictionary = {
	"turns_at_a_time": $TurnCount/NumberSelector,
	"turn_queue_time": $TurnQueueTime/NumberSelector,
	"turn_cooldown_time": $TurnCooldownTime/NumberSelector,
}

@onready
var turn_rules: Dictionary = {
	"turn_sequential": $TurnSequential/CheckBox,
	"turn_concurrent": $TurnConcurrent/CheckBox,
	"turn_queue": $TurnQueue/CheckBox,
	"turn_cooldown": $TurnCooldown/CheckBox,
}

@onready
var vc_buttons: Dictionary = {
	"victory_annihilation" = $Annihilation/CheckBox,
	"victory_all_sacred" = $VCSacred/SacredFields/AllSacredPiece/CheckBox,
	"victory_any_sacred" = $VCSacred/SacredFields/AnySacredPiece/CheckBox,
}

@onready
var modifier_buttons: Dictionary = {
	"divine_wind" = $DivineWind/CheckBox,
	"no_retreat" = $NoRetreat/CheckBox,
	"formation_broken" = $FormationBroken/CheckBox,
	"b_team" = $BTeam/CheckBox,
	"round_earth" = $RoundEarth/CheckBox,
	"polar_crossing" = $PolarCrossing/CheckBox,
	"no_gods" = $NoGods/CheckBox,
	"greater_good" = $GreaterGood/CheckBox,
	"foreign_ground" = $ForeignGround/CheckBox,
	"brave_and_stupid" = $BraveAndStupid/CheckBox,
	"ho_chi_minh" = $HoChiMinh/CheckBox,
	"patience" = $Patience/CheckBox,
}

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	button_can_players_edit.pressed.connect(_on_change)
	
	vc_buttons.victory_all_sacred.pressed.connect(func (): _set_victory_condition(vc_buttons.victory_all_sacred))
	vc_buttons.victory_any_sacred.pressed.connect(func (): _set_victory_condition(vc_buttons.victory_any_sacred))
	vc_buttons.victory_annihilation.pressed.connect(func (): _set_victory_condition(vc_buttons.victory_annihilation))
	
	turn_rules.turn_sequential.pressed.connect(func (): _set_turn_rule(turn_rules.turn_sequential))
	turn_rules.turn_concurrent.pressed.connect(func (): _set_turn_rule(turn_rules.turn_concurrent))
	turn_rules.turn_cooldown.pressed.connect(func (): _set_turn_rule(turn_rules.turn_cooldown))
	turn_rules.turn_queue.pressed.connect(func (): _set_turn_rule(turn_rules.turn_queue))
	
	turn_rule_selectors.turns_at_a_time.on_change.connect(_on_change)
	turn_rule_selectors.turn_cooldown_time.on_change.connect(_on_change)
	turn_rule_selectors.turn_queue_time.on_change.connect(_on_change)
	
	for b in modifier_buttons.values():
		b.pressed.connect(_on_change)
		
	settings = gather_settings()
	_set_victory_condition(vc_buttons.victory_annihilation)
	_set_turn_rule(turn_rules.turn_sequential)
	
	if multiplayer.is_server():
		update_buttons_clickable(true)
	else:
		update_buttons_clickable(false)
		request_load_settings.rpc_id(1)

func _on_visibility_changed():
	if visible:
		node_rule_info = PrefabController.get_prefab("Menus.Setup.RuleInfo").instantiate()
		GameController.screen_secondary.add_child(node_rule_info)
	else:
		Helpers.destroy_node(node_rule_info)

func _set_victory_condition(new_condition: CheckBox):
	# Flick off all but the new condition
	for b in vc_buttons.values():
		b.set_pressed_no_signal(false)
	
	new_condition.set_pressed_no_signal(true)
	_on_change()

func _set_turn_rule(new_rule: CheckBox):
	# Flick off all but the new condition
	for b in turn_rules.values():
		b.set_pressed_no_signal(false)
	
	new_rule.set_pressed_no_signal(true)
	
	if new_rule == turn_rules.turn_cooldown:
		turn_rule_selectors.turns_at_a_time.get_parent().visible = false
		turn_rule_selectors.turn_queue_time.get_parent().visible = false
		turn_rule_selectors.turn_cooldown_time.get_parent().visible = true
	elif new_rule == turn_rules.turn_queue:
		turn_rule_selectors.turns_at_a_time.get_parent().visible = false
		turn_rule_selectors.turn_queue_time.get_parent().visible = true
		turn_rule_selectors.turn_cooldown_time.get_parent().visible = false
	else:
		turn_rule_selectors.turns_at_a_time.get_parent().visible = true
		turn_rule_selectors.turn_queue_time.get_parent().visible = false
		turn_rule_selectors.turn_cooldown_time.get_parent().visible = false
	
	_on_change()

func _on_change():
	settings = gather_settings()
	if multiplayer.is_server():
		load_settings.rpc(settings.serialize())
	elif settings.can_players_edit:
		client_load_settings.rpc_id(1, settings.serialize())
	
func gather_settings() -> GameSettings:
	var settings = {}
	settings.can_players_edit = button_can_players_edit.button_pressed
	
	for s in turn_rule_selectors.keys():
		settings[s] = turn_rule_selectors[s].number
	for b in turn_rules.keys():
		settings[b] = turn_rules[b].button_pressed
	for b in vc_buttons.keys():
		settings[b] = vc_buttons[b].button_pressed
	for b in modifier_buttons.keys():
		settings[b] = modifier_buttons[b].button_pressed
	
	settings.victory_sacred_type = button_sacred_piece.current_piece
	return GameSettings.deserialize(settings)

func update_buttons_clickable(clickable: bool):
	if multiplayer.is_server():
		button_can_players_edit.disabled = false
	else:
		button_can_players_edit.disabled = true
	
	for button in modifier_buttons.values():
		button.disabled = !clickable
	for button in vc_buttons.values():
		button.disabled = !clickable
	for button in turn_rules.values():
		button.disabled = !clickable
	for selector in turn_rule_selectors.values():
		selector.left_arrow.disabled = !clickable
		selector.right_arrow.disabled = !clickable

@rpc("authority", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
	button_can_players_edit.set_pressed_no_signal(json_settings.can_players_edit)
	
	for k in turn_rule_selectors.keys():
		turn_rule_selectors[k].number = json_settings[k]
		turn_rule_selectors[k].number_label.text = str(json_settings[k])
	for k in turn_rules.keys():
		turn_rules[k].set_pressed_no_signal(json_settings[k])
	for k in modifier_buttons.keys():
		modifier_buttons[k].set_pressed_no_signal(json_settings[k])
	for k in vc_buttons.keys():
		vc_buttons[k].set_pressed_no_signal(json_settings[k])
	
	button_sacred_piece.current_piece = json_settings.victory_sacred_type
	button_sacred_piece._set_texture(json_settings.victory_sacred_type)
	
	if not multiplayer.is_server():
		update_buttons_clickable(json_settings.can_players_edit)
	settings = GameSettings.deserialize(json_settings)
	
@rpc("any_peer", "call_local", "reliable")
func client_load_settings(json_settings: Dictionary):
	if not multiplayer.is_server():
		return
	if not settings.can_players_edit:
		return
	load_settings.rpc(json_settings)

@rpc("any_peer", "call_remote", "reliable")
func request_load_settings():
	if not multiplayer.is_server():
		return
	load_settings.rpc_id(multiplayer.get_remote_sender_id(), settings.serialize())
