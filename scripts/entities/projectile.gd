extends Node2D
class_name Projectile

@export var speed: float = 430.0
@export var hit_radius: float = 12.0
@export var lifetime: float = 1.3
@export var target_group: String = "enemies"
@export var outer_color: Color = Color(0.03, 0.02, 0.07)
@export var inner_color: Color = Color(0.72, 0.38, 1.0)

var direction: Vector2 = Vector2.RIGHT
var damage: int = 8
var game: Node


func setup(
	start_position: Vector2,
	target_position: Vector2,
	amount: int,
	game_node: Node,
	projectile_target_group: String = "enemies",
	projectile_speed: float = 430.0,
	projectile_inner_color: Color = Color(0.72, 0.38, 1.0)
) -> void:
	# O projetil nasce ja sabendo ponto inicial, alvo inicial, dano e quem consulta inimigos.
	global_position = start_position
	direction = (target_position - start_position).normalized()
	damage = amount
	game = game_node
	target_group = projectile_target_group
	speed = projectile_speed
	inner_color = projectile_inner_color


func _process(delta: float) -> void:
	# Projetil usa _process porque nao depende de colisao fisica, so avanca por tempo.
	global_position += direction * speed * delta
	lifetime -= delta

	var target: Node2D = _find_hit_target()
	if target:
		target.call("take_damage", damage)
		if game.has_method("spawn_damage_feedback"):
			game.call("spawn_damage_feedback", damage, target.global_position, _get_feedback_color())
		queue_free()
		return

	if lifetime <= 0.0:
		queue_free()


func _find_hit_target() -> Node2D:
	if not is_instance_valid(game):
		return null

	if target_group == "player" and game.has_method("get_player_if_in_range"):
		return game.call("get_player_if_in_range", global_position, hit_radius) as Node2D

	if game.has_method("get_nearest_enemy"):
		return game.call("get_nearest_enemy", global_position, hit_radius) as Node2D

	return null


func _get_feedback_color() -> Color:
	if target_group == "player":
		return Color(1.0, 0.38, 0.3)

	return Color(1.0, 0.92, 0.58)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, outer_color)
	draw_circle(Vector2.ZERO, 3.5, inner_color)
