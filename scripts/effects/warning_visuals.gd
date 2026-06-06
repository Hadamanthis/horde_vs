extends RefCounted


static func set_area_node_color(area_node: Node2D, color: Color) -> void:
	var ring: Polygon2D = area_node.get_node_or_null("Ring") as Polygon2D
	if ring:
		ring.color = color

	var fill: Polygon2D = area_node.get_node_or_null("Fill") as Polygon2D
	if fill:
		fill.color = Color(color.r, color.g, color.b, color.a * 0.52)


static func configure_dash_warning(
	warning_line: Line2D,
	origin: Vector2,
	direction: Vector2,
	length: float,
	width: float,
	color: Color
) -> void:
	warning_line.top_level = true
	warning_line.visible = true
	warning_line.width = width
	warning_line.global_position = origin
	warning_line.global_rotation = direction.angle()
	warning_line.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2.RIGHT * length,
	])
	warning_line.default_color = color


static func hide_dash_warning(warning_line: Line2D) -> void:
	warning_line.visible = false
