extends Node2D

class_name Arena

@export var arena_name: String = "Arena"
@export var arena_size: Vector2 = Vector2(2400.0, 1600.0)
@export var ground_color: Color = Color(0.075, 0.105, 0.085)
@export var border_color: Color = Color(0.25, 0.36, 0.28)
@export var grid_color: Color = Color(0.12, 0.17, 0.14, 0.42)
@export var grid_size: float = 96.0

@onready var ground: Polygon2D = get_node_or_null("Ground") as Polygon2D
@onready var border: Line2D = get_node_or_null("Border") as Line2D


func _ready() -> void:
	_configure_visual_bounds()


func get_local_bounds() -> Rect2:
	return Rect2(-arena_size * 0.5, arena_size)


func get_global_bounds() -> Rect2:
	var local_bounds: Rect2 = get_local_bounds()
	return Rect2(global_position + local_bounds.position, local_bounds.size)


func get_global_spawn_bounds(margin: float = 160.0) -> Rect2:
	var bounds: Rect2 = get_global_bounds()
	var safe_margin: float = minf(margin, minf(bounds.size.x, bounds.size.y) * 0.25)
	return bounds.grow(-safe_margin)


func _configure_visual_bounds() -> void:
	var bounds: Rect2 = get_local_bounds()
	var corners: PackedVector2Array = PackedVector2Array([
		bounds.position,
		bounds.position + Vector2(bounds.size.x, 0.0),
		bounds.position + bounds.size,
		bounds.position + Vector2(0.0, bounds.size.y),
	])

	if is_instance_valid(ground):
		ground.color = ground_color
		ground.polygon = corners

	if is_instance_valid(border):
		border.default_color = border_color
		border.width = 10.0
		border.closed = true
		border.points = corners

	queue_redraw()


func _draw() -> void:
	var bounds: Rect2 = get_local_bounds()
	var start_x: float = floorf(bounds.position.x / grid_size) * grid_size
	var start_y: float = floorf(bounds.position.y / grid_size) * grid_size
	var end_x: float = bounds.position.x + bounds.size.x
	var end_y: float = bounds.position.y + bounds.size.y

	var x: float = start_x
	while x <= end_x:
		draw_line(Vector2(x, bounds.position.y), Vector2(x, end_y), grid_color, 1.0)
		x += grid_size

	var y: float = start_y
	while y <= end_y:
		draw_line(Vector2(bounds.position.x, y), Vector2(end_x, y), grid_color, 1.0)
		y += grid_size
