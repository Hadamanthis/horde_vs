extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

@export var max_health: int = 24
@export var speed: float = 68.0
@export var contact_damage: int = 8
@export var contact_range: float = 23.0
@export var contact_interval: float = 0.75
@export var convertible: bool = true

var player: Node2D
var current_health: int = max_health
var _contact_timer: float = 0.0
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

	# IA minima do MVP: andar em linha reta na direcao do jogador.
	var to_player: Vector2 = player.global_position - global_position
	velocity = to_player.normalized() * speed
	move_and_slide()

	# Dano por contato usa distancia, nao colisao fisica, para manter o prototipo simples.
	_contact_timer = maxf(_contact_timer - delta, 0.0)
	if to_player.length() <= contact_range and _contact_timer == 0.0:
		if player.has_method("take_damage"):
			player.take_damage(contact_damage)
		_contact_timer = contact_interval

	if _hit_flash_time > 0.0:
		_hit_flash_time -= delta
		queue_redraw()


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
