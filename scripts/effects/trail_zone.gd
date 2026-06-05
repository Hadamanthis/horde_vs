extends Node2D
class_name TrailZone

@export var damage: int = 3
@export var radius: float = 28.0
@export var duration: float = 2.4
@export var tick_interval: float = 0.45
@export var target_group: String = "player"
@export var fill_color: Color = Color(0.55, 0.95, 0.28, 0.42)

@onready var visual: Node2D = $Visual as Node2D
@onready var fill: Polygon2D = $Visual/Fill as Polygon2D
@onready var ring: Polygon2D = $Visual/Ring as Polygon2D

var game: Node
var _age: float = 0.0
var _tick_timer: float = 0.0


func setup(
	game_node: Node,
	zone_target_group: String,
	zone_damage: int,
	zone_radius: float,
	zone_duration: float,
	zone_tick_interval: float,
	zone_color: Color
) -> void:
	game = game_node
	target_group = zone_target_group
	damage = zone_damage
	radius = zone_radius
	duration = zone_duration
	tick_interval = zone_tick_interval
	fill_color = zone_color


func _ready() -> void:
	# A cena usa um poligono pequeno como base e escala pelo raio configurado na entidade que criou o rastro.
	visual.scale = Vector2.ONE * (radius / 32.0)
	fill.color = fill_color
	ring.color = Color(fill_color.r, fill_color.g, fill_color.b, minf(fill_color.a + 0.2, 0.72))


func _process(delta: float) -> void:
	_age += delta
	_tick_timer = maxf(_tick_timer - delta, 0.0)

	var fade: float = clampf(1.0 - _age / duration, 0.0, 1.0)
	modulate.a = fade

	if _tick_timer == 0.0:
		_apply_tick_damage()
		_tick_timer = tick_interval

	if _age >= duration:
		queue_free()


func _apply_tick_damage() -> void:
	if not is_instance_valid(game):
		return

	# Um mesmo rastro serve para inimigos ou aliados mudando apenas o grupo alvo.
	if target_group == "player":
		var player: Player = game.call("get_player_if_in_range", global_position, radius) as Player
		if player:
			player.take_damage(damage)
			_emit_feedback(damage, player.global_position, Color(1.0, 0.38, 0.3))
		return

	var enemy_nodes: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy_node in enemy_nodes:
		var enemy: Enemy = enemy_node as Enemy
		if not is_instance_valid(enemy):
			continue

		if global_position.distance_to(enemy.global_position) > radius:
			continue

		var actual_damage: int = enemy.take_damage(damage, "area")
		if actual_damage > 0:
			_emit_feedback(actual_damage, enemy.global_position, Color(0.55, 1.0, 0.82))


func _emit_feedback(amount: int, world_position: Vector2, tint: Color) -> void:
	if game.has_method("spawn_damage_feedback"):
		game.call("spawn_damage_feedback", amount, world_position, tint)
