extends Node2D
class_name Projectile

@export var speed: float = 430.0
@export var hit_radius: float = 12.0
@export var lifetime: float = 1.3

var direction: Vector2 = Vector2.RIGHT
var damage: int = 8
var game: Node


func setup(start_position: Vector2, target_position: Vector2, amount: int, game_node: Node) -> void:
	# O projetil nasce ja sabendo ponto inicial, alvo inicial, dano e quem consulta inimigos.
	global_position = start_position
	direction = (target_position - start_position).normalized()
	damage = amount
	game = game_node


func _process(delta: float) -> void:
	# Projetil usa _process porque nao depende de colisao fisica, so avanca por tempo.
	global_position += direction * speed * delta
	lifetime -= delta

	var enemy: Enemy = _find_hit_enemy()
	if enemy:
		enemy.take_damage(damage)
		if game.has_method("spawn_damage_feedback"):
			game.call("spawn_damage_feedback", damage, enemy.global_position)
		queue_free()
		return

	if lifetime <= 0.0:
		queue_free()


func _find_hit_enemy() -> Enemy:
	if not is_instance_valid(game) or not game.has_method("get_nearest_enemy"):
		return null

	return game.call("get_nearest_enemy", global_position, hit_radius) as Enemy


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(0.03, 0.02, 0.07))
	draw_circle(Vector2.ZERO, 3.5, Color(0.72, 0.38, 1.0))
