extends Node2D
class_name Pickup

signal collected(pickup: Node2D, pickup_type: String)
signal expired(pickup: Node2D)

@export var pickup_type: String = "health"
@export var collect_radius: float = 38.0
@export var lifetime: float = 12.0

@onready var visual: Node2D = $Visual as Node2D
@onready var collect_collision_shape: CollisionShape2D = get_node_or_null("CollectArea/CollisionShape2D") as CollisionShape2D
@onready var halo: Polygon2D = $Visual/Halo as Polygon2D
@onready var glow: Polygon2D = $Visual/Glow as Polygon2D
@onready var core: Polygon2D = $Visual/Core as Polygon2D
@onready var type_label: Label = $Visual/TypeLabel as Label

var player: Node2D
var _pulse_time: float = 0.0


func _ready() -> void:
	_sync_collect_shape()
	_apply_pickup_visual()


func setup(target_player: Node2D, new_pickup_type: String) -> void:
	player = target_player
	pickup_type = new_pickup_type
	if is_node_ready():
		_sync_collect_shape()
		_apply_pickup_visual()


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_pulse_time += delta
	lifetime = maxf(lifetime - delta, 0.0)
	if lifetime == 0.0:
		expired.emit(self)
		queue_free()
		return

	if global_position.distance_to(player.global_position) <= collect_radius:
		collected.emit(self, pickup_type)
		queue_free()
		return

	var pulse: float = 1.0 + sin(_pulse_time * 6.0) * 0.12
	visual.scale = Vector2.ONE * pulse
	visual.rotation = sin(_pulse_time * 2.0) * 0.12
	type_label.rotation = -visual.rotation


func _apply_pickup_visual() -> void:
	if pickup_type == "xp_vacuum":
		halo.color = Color(0.03, 0.08, 0.16, 0.76)
		glow.color = Color(0.26, 0.78, 1.0, 0.46)
		core.color = Color(0.68, 0.95, 1.0, 0.95)
		core.polygon = PackedVector2Array([
			Vector2(0, -14), Vector2(5, -4), Vector2(15, -4), Vector2(7, 3),
			Vector2(10, 13), Vector2(0, 7), Vector2(-10, 13), Vector2(-7, 3),
			Vector2(-15, -4), Vector2(-5, -4),
		])
		type_label.text = "*"
		type_label.add_theme_color_override("font_color", Color(0.9, 1.0, 1.0, 1.0))
		return

	halo.color = Color(0.12, 0.03, 0.04, 0.76)
	glow.color = Color(1.0, 0.2, 0.32, 0.46)
	core.color = Color(1.0, 0.42, 0.52, 0.95)
	core.polygon = PackedVector2Array([
		Vector2(0, -14), Vector2(5, -6), Vector2(13, -6), Vector2(13, 3),
		Vector2(5, 3), Vector2(5, 13), Vector2(-5, 13), Vector2(-5, 3),
		Vector2(-13, 3), Vector2(-13, -6), Vector2(-5, -6),
	])
	type_label.text = "+"
	type_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.94, 1.0))


func _sync_collect_shape() -> void:
	if not collect_collision_shape or not (collect_collision_shape.shape is CircleShape2D):
		return

	var circle_shape: CircleShape2D = collect_collision_shape.shape.duplicate() as CircleShape2D
	circle_shape.radius = collect_radius
	collect_collision_shape.shape = circle_shape
