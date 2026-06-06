extends Node2D
class_name CaptureEssence

signal collection_requested(essence: Node2D, enemy_type: String)
signal expired(essence: Node2D)

@export var enemy_type: String = "slime"
@export var collect_radius: float = 34.0
@export var lifetime: float = 8.0
@export var retry_interval: float = 0.35

@onready var visual: Node2D = $Visual as Node2D
@onready var collect_collision_shape: CollisionShape2D = get_node_or_null("CollectArea/CollisionShape2D") as CollisionShape2D
@onready var halo: Polygon2D = $Visual/Halo as Polygon2D
@onready var glow: Polygon2D = $Visual/Glow as Polygon2D
@onready var core: Polygon2D = $Visual/Core as Polygon2D
@onready var type_label: Label = $Visual/TypeLabel as Label

var player: Node2D
var _pulse_time: float = 0.0
var _retry_timer: float = 0.0


func _ready() -> void:
	_sync_collect_shape()
	_apply_type_visual()


func setup(target_player: Node2D, captured_enemy_type: String) -> void:
	# Diferente do XP, a essencia nao tem magnetismo: o jogador escolhe pegar.
	player = target_player
	enemy_type = captured_enemy_type
	if is_node_ready():
		_sync_collect_shape()
		_apply_type_visual()


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_pulse_time += delta
	lifetime = maxf(lifetime - delta, 0.0)
	_retry_timer = maxf(_retry_timer - delta, 0.0)

	if lifetime == 0.0:
		expired.emit(self)
		queue_free()
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)
	if distance_to_player <= collect_radius and _retry_timer == 0.0:
		_retry_timer = retry_interval
		collection_requested.emit(self, enemy_type)

	var pulse: float = 1.0 + sin(_pulse_time * 7.0) * 0.14
	visual.scale = Vector2.ONE * pulse
	visual.rotation = sin(_pulse_time * 2.5) * 0.16
	type_label.rotation = -visual.rotation


func _apply_type_visual() -> void:
	# A essencia precisa comunicar o tipo antes da coleta; cor + silhueta + letra ajudam no prototipo.
	var colors: Dictionary = _get_type_colors(enemy_type)
	halo.color = colors["halo"]
	glow.color = colors["glow"]
	core.color = colors["core"]
	core.polygon = _get_type_polygon(enemy_type)
	type_label.text = _get_type_abbreviation(enemy_type)
	type_label.add_theme_color_override("font_color", colors["label"])


func _sync_collect_shape() -> void:
	if not collect_collision_shape or not (collect_collision_shape.shape is CircleShape2D):
		return

	var circle_shape: CircleShape2D = collect_collision_shape.shape.duplicate() as CircleShape2D
	circle_shape.radius = collect_radius
	collect_collision_shape.shape = circle_shape


func _get_type_colors(type_name: String) -> Dictionary:
	match type_name:
		"bat":
			return {
				"halo": Color(0.08, 0.02, 0.16, 0.72),
				"glow": Color(0.58, 0.32, 1.0, 0.42),
				"core": Color(0.72, 0.46, 1.0, 0.88),
				"label": Color(0.96, 0.9, 1.0, 1.0),
			}
		"boar":
			return {
				"halo": Color(0.18, 0.07, 0.02, 0.72),
				"glow": Color(1.0, 0.48, 0.18, 0.42),
				"core": Color(1.0, 0.64, 0.28, 0.9),
				"label": Color(1.0, 0.94, 0.86, 1.0),
			}
		"totem":
			return {
				"halo": Color(0.08, 0.11, 0.04, 0.72),
				"glow": Color(0.8, 0.9, 0.24, 0.42),
				"core": Color(0.94, 0.86, 0.3, 0.9),
				"label": Color(1.0, 0.98, 0.8, 1.0),
			}
		"spitter":
			return {
				"halo": Color(0.02, 0.12, 0.14, 0.72),
				"glow": Color(0.25, 0.95, 1.0, 0.42),
				"core": Color(0.48, 1.0, 0.92, 0.9),
				"label": Color(0.88, 1.0, 0.98, 1.0),
			}
		"crawler":
			return {
				"halo": Color(0.04, 0.13, 0.03, 0.72),
				"glow": Color(0.46, 1.0, 0.24, 0.42),
				"core": Color(0.62, 1.0, 0.36, 0.9),
				"label": Color(0.92, 1.0, 0.84, 1.0),
			}
		"shield":
			return {
				"halo": Color(0.02, 0.07, 0.16, 0.72),
				"glow": Color(0.32, 0.62, 1.0, 0.42),
				"core": Color(0.58, 0.82, 1.0, 0.9),
				"label": Color(0.88, 0.95, 1.0, 1.0),
			}
		_:
			return {
				"halo": Color(0.03, 0.14, 0.07, 0.72),
				"glow": Color(0.24, 1.0, 0.62, 0.42),
				"core": Color(0.55, 1.0, 0.82, 0.9),
				"label": Color(0.88, 1.0, 0.94, 1.0),
			}


func _get_type_polygon(type_name: String) -> PackedVector2Array:
	match type_name:
		"bat":
			return PackedVector2Array([Vector2(-16, -3), Vector2(-7, -11), Vector2(0, -3), Vector2(7, -11), Vector2(16, -3), Vector2(7, 5), Vector2(0, 12), Vector2(-7, 5)])
		"boar":
			return PackedVector2Array([Vector2(-13, -4), Vector2(-5, -10), Vector2(8, -8), Vector2(14, 0), Vector2(8, 8), Vector2(-5, 10), Vector2(-13, 4)])
		"totem":
			return PackedVector2Array([Vector2(-7, -13), Vector2(7, -13), Vector2(9, -5), Vector2(6, 13), Vector2(-6, 13), Vector2(-9, -5)])
		"spitter":
			return PackedVector2Array([Vector2(0, -14), Vector2(9, -5), Vector2(5, 12), Vector2(0, 15), Vector2(-5, 12), Vector2(-9, -5)])
		"crawler":
			return PackedVector2Array([Vector2(-15, -5), Vector2(-6, -10), Vector2(6, -10), Vector2(15, -5), Vector2(15, 5), Vector2(6, 10), Vector2(-6, 10), Vector2(-15, 5)])
		"shield":
			return PackedVector2Array([Vector2(0, -14), Vector2(11, -8), Vector2(10, 5), Vector2(0, 14), Vector2(-10, 5), Vector2(-11, -8)])
		_:
			return PackedVector2Array([Vector2(0, -12), Vector2(10, -6), Vector2(12, 5), Vector2(4, 13), Vector2(-7, 11), Vector2(-13, 2), Vector2(-9, -8)])


func _get_type_abbreviation(type_name: String) -> String:
	match type_name:
		"bat":
			return "B"
		"boar":
			return "J"
		"totem":
			return "T"
		"spitter":
			return "A"
		"crawler":
			return "R"
		"shield":
			return "E"
		_:
			return "S"
