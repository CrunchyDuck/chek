extends Control

@export_multiline
var rule_name: String
@export_multiline
var rule_description: String

var rule_info: Control:
	get:
		return RightScreenController.instance.node_container.get_node("RuleInfo")
var label_description: Label:
	get:
		return rule_info.get_node("Description")
var label_name: Label:
	get:
		return rule_info.get_node("Name")

func _ready():
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	if rule_info == null:
		print("Rule info null")
		return
	label_name.text = rule_name
	label_description.text = rule_description
