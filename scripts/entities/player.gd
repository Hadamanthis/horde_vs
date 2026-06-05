extends CharacterBody2D
class_name Player

signal died
signal health_changed(current_health: int, max_health: int)

@export var max_health: int = 100
@export var speed: float = 160.0
@export var projectile_damage: int = 8
@export var attack_interval: float = 1.0
@export var attack_range: float = 420.0

@onready var body_visual: Polygon2D = $Visual/Body as Polygon2D

var current_health: int = max_health
var can_move: bool = true
var _hit_flash_time: float = 0.0


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	_update_visual()


func _physics_process(delta: float) -> void:
	# _physics_process roda em passo fixo, ideal para movimento de CharacterBody2D.
	var direction: Vector2 = Vector2.ZERO
	if can_move:
		direction = _read_move_input()

	velocity = direction * speed
	move_and_slide()

	if _hit_flash_time > 0.0:
		_hit_flash_time -= delta
		_update_visual()


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health = maxi(current_health - amount, 0)
	_hit_flash_time = 0.12
	health_changed.emit(current_health, max_health)
	_update_visual()

	if current_health == 0:
		died.emit()


func increase_max_health(amount: int) -> void:
	# Upgrade defensivo: aumenta vida maxima e cura o mesmo valor para ser sentido na hora.
	max_health += amount
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	_update_visual()


func set_control_enabled(is_enabled: bool) -> void:
	# O Game chama isso na derrota para separar "personagem existe" de "jogador controla".
	can_move = is_enabled
	if not can_move:
		velocity = Vector2.ZERO


func _read_move_input() -> Vector2:
	var direction: Vector2 = Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	return direction.normalized()


func _update_visual() -> void:
	# O visual fica como nos filhos na cena; o script so troca cor no feedback de dano.
	var body_color: Color = Color(0.24, 0.78, 1.0)
	if _hit_flash_time > 0.0:
		body_color = Color(1.0, 1.0, 1.0)

	body_visual.color = body_color
