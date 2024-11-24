class_name SecondaryScreenController
extends Node

@onready
var viewport: Viewport = $".."

@onready
var left_button: Array[PressButton] = [
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryLeftButton1/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryLeftButton2/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryLeftButton3/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryLeftButton4/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryLeftButton5/PressButton",
]

@onready
var right_button: Array[PressButton] = [
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryRightButton1/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryRightButton2/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryRightButton3/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryRightButton4/PressButton",
  $"/root/MainScene/Console/right_panel/RightScreenFrame/SecondaryRightButton5/PressButton",
]

@onready
var power: PowerCoordinator = $"/root/MainScene/Console/right_panel/RightScreenFrame/ScreenRightPower/PowerCoordinator"
