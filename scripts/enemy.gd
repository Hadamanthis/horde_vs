extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

@export var max_health := 24
@export var speed := 68.0
@export var contact_damage := 8
@export var contact_range := 23.0
@export var contact_interval := 0.75
@export var convertible := true

var player: Node2D
var current_health := max_health
var _contact_timer := 0.0
var _hit_flash_time := 0.0


func setup(target_player: Node2D) -> void:
	player = target_player


func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player := player.global_position - global_position
	velocity = to_player.normalized() * speed
	move_and_slide()

	_contact_timer = max(_contact_timer - delta, 0.0)
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

	current_health -= amount
	_hit_flash_time = 0.08
	queue_redraw()

	if current_health <= 0:
		died.emit(self)
		queue_free()


func _draw() -> void:
	var body_color := Color(0.9, 0.22, 0.2)
	if _hit_flash_time > 0.0:
		body_color = Color(1.0, 0.95, 0.72)

	draw_circle(Vector2.ZERO, 12.0, Color(0.18, 0.02, 0.02))
	draw_circle(Vector2.ZERO, 9.0, body_color)
	draw_circle(Vector2(-3.0, -2.0), 1.6, Color(0.08, 0.01, 0.01))
	draw_circle(Vector2(3.0, -2.0), 1.6, Color(0.08, 0.01, 0.01))
