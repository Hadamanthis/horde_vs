extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

@export var max_health: int = 24
@export var speed: float = 68.0
@export var contact_range: float = 23.0
@export var convertible: bool = true
@export var separation_radius: float = 30.0
@export var separation_force: float = 1.35

var player: Node2D
var current_health: int = max_health
var _hit_flash_time: float = 0.0


func setup(target_player: Node2D) -> void:
	# O Game injeta a referencia do jogador quando cria o inimigo.
	player = target_player


func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# IA minima do MVP: perseguir o jogador, mas mantendo separacao visual entre slimes.
	var to_player: Vector2 = player.global_position - global_position
	var chase_direction: Vector2 = to_player.normalized()
	var separation_direction: Vector2 = _get_separation_direction()
	var move_direction: Vector2 = (chase_direction + separation_direction * separation_force).normalized()
	velocity = move_direction * speed
	move_and_slide()

	if _hit_flash_time > 0.0:
		_hit_flash_time -= delta
		queue_redraw()


func _get_separation_direction() -> Vector2:
	# Separacao simples evita pilhas perfeitas sem precisar de pathfinding ou fisica pesada.
	var separation: Vector2 = Vector2.ZERO
	var neighbors: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for neighbor in neighbors:
		if neighbor == self or not is_instance_valid(neighbor):
			continue

		var other_enemy: Node2D = neighbor as Node2D
		var away: Vector2 = global_position - other_enemy.global_position
		var distance: float = away.length()
		if distance > 0.0 and distance < separation_radius:
			separation += away.normalized() * (1.0 - distance / separation_radius)

	return separation.normalized()


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	# O flash visual confirma que o inimigo recebeu dano mesmo sem sprite/animacao.
	current_health -= amount
	_hit_flash_time = 0.08
	queue_redraw()

	if current_health <= 0:
		died.emit(self)
		queue_free()


func _draw() -> void:
	# Vermelho identifica ameacas; aliados usam verde para separar times rapidamente.
	var body_color: Color = Color(0.9, 0.22, 0.2)
	if _hit_flash_time > 0.0:
		body_color = Color(1.0, 0.95, 0.72)

	draw_circle(Vector2.ZERO, 12.0, Color(0.18, 0.02, 0.02))
	draw_circle(Vector2.ZERO, 9.0, body_color)
	draw_circle(Vector2(-3.0, -2.0), 1.6, Color(0.08, 0.01, 0.01))
	draw_circle(Vector2(3.0, -2.0), 1.6, Color(0.08, 0.01, 0.01))
