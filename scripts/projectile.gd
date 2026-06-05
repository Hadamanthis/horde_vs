extends Node2D

@export var speed := 430.0
@export var hit_radius := 12.0
@export var lifetime := 1.3

var direction := Vector2.RIGHT
var damage := 8
var game: Node


func setup(start_position: Vector2, target_position: Vector2, amount: int, game_node: Node) -> void:
	global_position = start_position
	direction = (target_position - start_position).normalized()
	damage = amount
	game = game_node


func _process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta

	var enemy := _find_hit_enemy()
	if enemy:
		enemy.take_damage(damage)
		queue_free()
		return

	if lifetime <= 0.0:
		queue_free()


func _find_hit_enemy() -> Node2D:
	if not is_instance_valid(game) or not game.has_method("get_nearest_enemy"):
		return null

	return game.get_nearest_enemy(global_position, hit_radius)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(0.03, 0.02, 0.07))
	draw_circle(Vector2.ZERO, 3.5, Color(0.72, 0.38, 1.0))
