extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

@export var max_health: int = 24
@export var speed: float = 68.0
@export var contact_damage: int = 6
@export var contact_range: float = 23.0
@export var convertible: bool = true
@export var enemy_type: String = "slime"
@export var xp_value: int = 1
@export var movement_mode: String = "chase"
@export var preferred_distance: float = 120.0
@export var separation_radius: float = 24.0
@export var separation_force: float = 0.55
@export var dash_trigger_range: float = 230.0
@export var dash_speed: float = 320.0
@export var dash_windup_time: float = 0.35
@export var dash_duration: float = 0.28
@export var dash_cooldown: float = 1.25
@export var outline_color: Color = Color(0.18, 0.02, 0.02)
@export var body_color: Color = Color(0.9, 0.22, 0.2)
@export var eye_color: Color = Color(0.08, 0.01, 0.01)
@export var hit_flash_color: Color = Color(1.0, 0.95, 0.72)

@onready var outline_visual: Polygon2D = $Visual/Outline as Polygon2D
@onready var body_visual: Polygon2D = $Visual/Body as Polygon2D
@onready var left_eye_visual: Polygon2D = $Visual/LeftEye as Polygon2D
@onready var right_eye_visual: Polygon2D = $Visual/RightEye as Polygon2D

var player: Node2D
var current_health: int = max_health
var _hit_flash_time: float = 0.0
var _strafe_sign: float = 1.0
var _is_winding_up_dash: bool = false
var _dash_direction: Vector2 = Vector2.ZERO
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_windup_timer: float = 0.0


func setup(target_player: Node2D) -> void:
	# O Game injeta a referencia do jogador quando cria o inimigo.
	player = target_player


func _ready() -> void:
	current_health = max_health
	_strafe_sign = -1.0 if randf() < 0.5 else 1.0
	add_to_group("enemies")
	_update_visual()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# Cada cena escolhe um modo de movimento simples pelo Inspector.
	velocity = _get_velocity_for_movement_mode(delta)
	move_and_slide()

	if _hit_flash_time > 0.0:
		_hit_flash_time -= delta
		_update_visual()


func _get_velocity_for_movement_mode(delta: float) -> Vector2:
	match movement_mode:
		"charger":
			return _get_charger_velocity(delta)
		"skirmisher":
			return _get_directional_velocity(_get_skirmisher_direction())
		_:
			return _get_directional_velocity(_get_chase_direction())


func _get_directional_velocity(base_direction: Vector2) -> Vector2:
	var separation_direction: Vector2 = _get_separation_direction()
	var move_direction: Vector2 = (base_direction + separation_direction * separation_force).normalized()
	return move_direction * speed


func _get_chase_direction() -> Vector2:
	return (player.global_position - global_position).normalized()


func _get_skirmisher_direction() -> Vector2:
	# Skirmisher tenta incomodar em volta do jogador em vez de empilhar no centro.
	var to_player: Vector2 = player.global_position - global_position
	var distance_to_player: float = to_player.length()
	if distance_to_player <= 0.001:
		return Vector2.ZERO

	var chase_direction: Vector2 = to_player.normalized()
	if distance_to_player > preferred_distance:
		return chase_direction
	if distance_to_player < preferred_distance * 0.72:
		return -chase_direction

	return chase_direction.rotated(PI * 0.5 * _strafe_sign)


func _get_charger_velocity(delta: float) -> Vector2:
	# Charger cria uma leitura de perigo: prepara, avanca em linha reta, depois recupera.
	if _dash_timer > 0.0:
		_dash_timer = maxf(_dash_timer - delta, 0.0)
		if _dash_timer == 0.0:
			_dash_cooldown_timer = dash_cooldown
		return _dash_direction * dash_speed

	if _is_winding_up_dash:
		_dash_windup_timer = maxf(_dash_windup_timer - delta, 0.0)
		if _dash_windup_timer == 0.0:
			_is_winding_up_dash = false
			_dash_direction = _get_chase_direction()
			_dash_timer = dash_duration
		return Vector2.ZERO

	if _dash_cooldown_timer > 0.0:
		_dash_cooldown_timer = maxf(_dash_cooldown_timer - delta, 0.0)
		return _get_chase_direction() * speed * 0.45

	var distance_to_player: float = global_position.distance_to(player.global_position)
	if distance_to_player <= dash_trigger_range:
		_is_winding_up_dash = true
		_dash_windup_timer = dash_windup_time
		return Vector2.ZERO

	return _get_directional_velocity(_get_chase_direction())


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
	_update_visual()

	if current_health <= 0:
		died.emit(self)
		queue_free()


func _update_visual() -> void:
	# Cada cena concreta define suas cores; o script so aplica feedback de dano.
	var visible_body_color: Color = body_color
	if _hit_flash_time > 0.0:
		visible_body_color = hit_flash_color

	outline_visual.color = outline_color
	body_visual.color = visible_body_color
	left_eye_visual.color = eye_color
	right_eye_visual.color = eye_color
