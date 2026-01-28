extends Node

@export var scale: float = 1.5

func _ready() -> void:
	# Scale existing controls then watch for new ones
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	_scale_existing(get_tree().get_root())

func _on_node_added(node: Node) -> void:
	if node is Control:
		_scale_control(node)

func _scale_existing(root: Node) -> void:
	for child in root.get_children():
		if child is Control:
			_scale_control(child)
		_scale_existing(child)

func _scale_control(control: Control) -> void:
	# Avoid double-scaling
	if control.has_meta("_ui_text_scaled"):
		return
	control.set_meta("_ui_text_scaled", true)

	# Try to read the current theme font size for this control
	var cur_size := 0
	if control.has_method("get_theme_font_size"):
		cur_size = control.get_theme_font_size("font_size")
	if cur_size > 0:
		var new_size := int(max(8, round(cur_size * scale)))
		control.add_theme_font_size_override("font_size", new_size)
		return

	# Fallback: set sensible defaults for common control types
	var default_size := 14
	if control is Label:
		default_size = 16
	elif control is Button:
		default_size = 15
	elif control is LineEdit:
		default_size = 14
	elif control is RichTextLabel:
		default_size = 16

	control.add_theme_font_size_override("font_size", int(round(default_size * scale)))
