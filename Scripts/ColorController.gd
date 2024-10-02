class_name ColorController
extends Node

const color_count = 8
const color_spacing = 1.0 / (color_count - 1.0)

const colors = {
  primary = Color(0, 0, 0),
  secondary = Color(1, 1, 1),
  c1 = Color(color_spacing * 1, color_spacing * 1, color_spacing * 1),
  c2 = Color(color_spacing * 2, color_spacing * 2, color_spacing * 2),
  c3 = Color(color_spacing * 3, color_spacing * 3, color_spacing * 3),
  c4 = Color(color_spacing * 4, color_spacing * 4, color_spacing * 4),
  c5 = Color(color_spacing * 5, color_spacing * 5, color_spacing * 5),
  c6 = Color(color_spacing * 6, color_spacing * 6, color_spacing * 6),
}
