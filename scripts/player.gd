extends CharacterBody2D
class_name Player

signal died
signal health_changed(current_health: int, max_health: int)

@export var max_health := 100
@export var speed := 160.0
@export var projectile_damage := 8
@export var attack_interval := 1.0
@export var attack_range := 420.0

var current_health := max_health
var _hit_flash_time := 0.0


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	var direction := _read_move_input()
	velocity = direction * speed
	move_and_slide()

	if _hit_flash_time > 0.0:
		_hit_flash_time -= delta
		queue_redraw()


func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	current_health = max(current_health - amount, 0)
	_hit_flash_time = 0.12
	health_changed.emit(current_health, max_health)
	queue_redraw()

	if current_health == 0:
		died.emit()


func _read_move_input() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	return direction.normalized()


func _draw() -> void:
	var body_color := Color(0.24, 0.78, 1.0)
	if _hit_flash_time > 0.0:
		body_color = Color(1.0, 1.0, 1.0)

	draw_circle(Vector2.ZERO, 14.0, Color(0.06, 0.12, 0.18))
	draw_circle(Vector2.ZERO, 11.0, body_color)
	draw_circle(Vector2(4.0, -3.0), 2.0, Color(0.02, 0.04, 0.06))
