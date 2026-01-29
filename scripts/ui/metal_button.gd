extends PanelContainer

## PanelContainer custom pour bouton métallisé avec dégradé radial

@export var border_color: Color = Color(0.7, 0.7, 0.7)
@export var border_width: int = 4
@export var corner_radius: int = 16

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Stylebox transparent pour laisser voir le _draw
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(.5,0,0,0)
	stylebox.border_color = border_color
	stylebox.border_width_top = border_width
	stylebox.border_width_bottom = border_width + 1
	stylebox.border_width_left = border_width
	stylebox.border_width_right = border_width
	stylebox.corner_radius_top_left = corner_radius
	stylebox.corner_radius_top_right = corner_radius
	stylebox.corner_radius_bottom_left = corner_radius
	stylebox.corner_radius_bottom_right = corner_radius
	self.add_theme_stylebox_override("panel", stylebox)
	queue_redraw()

func _draw():
	# Dégradé radial métallisé sur la zone du bouton
	var rect = Rect2(Vector2.ZERO, size)
	var radial_tex = _make_radial_grey_metal_gradient(size)
	draw_texture_rect(radial_tex, rect, false)
	# Highlight spéculaire
	var highlight_height = size.y * 0.22
	var highlight_y = size.y * 0.13
	var highlight_rect = Rect2(size.x * 0.12, highlight_y, size.x * 0.76, highlight_height)
	var grad = GradientTexture2D.new()
	grad.gradient = Gradient.new()
	grad.gradient.colors = [Color(1,1,1,0.38), Color(1,1,1,0.12), Color(1,1,1,0.0)]
	grad.gradient.offsets = [0.0, 0.7, 1.0]
	grad.width = int(highlight_rect.size.x)
	grad.height = int(highlight_rect.size.y)
	draw_texture_rect(grad, highlight_rect, false)

func _make_radial_grey_metal_gradient(button_size: Vector2) -> ImageTexture:
	var img := Image.create(int(button_size.x), int(button_size.y), false, Image.FORMAT_RGBA8)
	var center := button_size / 2.0
	var radius := float(min(button_size.x, button_size.y)) * 0.5
	for y in range(int(button_size.y)):
		for x in range(int(button_size.x)):
			var dist := ((Vector2(x, y) - center).length()) / radius
			dist = clamp(dist, 0.0, 1.0)
			var c := Color(0.85, 0.86, 0.89).lerp(Color(0.32, 0.34, 0.38), pow(dist, 1.5))
			var noise := randf_range(-0.04, 0.04)
			c.r = clamp(c.r + noise, 0, 1)
			c.g = clamp(c.g + noise, 0, 1)
			c.b = clamp(c.b + noise, 0, 1)
			img.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(img)
	return tex
