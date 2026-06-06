extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)
signal projectile_requested(start_position: Vector2, target_position: Vector2, damage: int, projectile_speed: float, projectile_color: Color)
signal trail_requested(spawn_position: Vector2, target_group: String, damage: int, radius: float, duration: float, tick_interval: float, color: Color)
signal area_attack_used(target_position: Vector2, damage: int)

const WARNING_VISUALS = preload("res://scripts/effects/warning_visuals.gd")

@export var max_health: int = 24
@export var speed: float = 68.0
@export var contact_damage: int = 6
@export var contact_range: float = 23.0
@export var convertible: bool = true
@export var enemy_type: String = "slime"
@export var xp_value: int = 1
@export var ranged_damage_multiplier: float = 1.0
@export var movement_mode: String = "chase"
@export var preferred_distance: float = 120.0
@export var separation_radius: float = 24.0
@export var separation_force: float = 0.55
@export var dash_trigger_range: float = 230.0
@export var dash_speed: float = 320.0
@export var dash_windup_time: float = 0.35
@export var dash_duration: float = 0.28
@export var dash_cooldown: float = 1.25
@export var dash_warning_width: float = 34.0
@export var dash_warning_color: Color = Color(1.0, 0.48, 0.16, 0.52)
@export var shoots_projectiles: bool = false
@export var projectile_damage: int = 5
@export var projectile_range: float = 260.0
@export var projectile_interval: float = 1.4
@export var projectile_speed: float = 250.0
@export var projectile_color: Color = Color(1.0, 0.55, 0.2)
@export var uses_area_attack: bool = false
@export var area_damage: int = 5
@export var area_range: float = 88.0
@export var area_interval: float = 1.5
@export var area_windup_time: float = 0.0
@export var area_target_mode: String = "self"
@export var area_feedback_color: Color = Color(0.48, 1.0, 0.82, 0.42)
@export var area_warning_color: Color = Color(1.0, 0.86, 0.28, 0.72)
@export var area_aura_color: Color = Color(0.16, 0.9, 0.72, 0.3)
@export var keeps_area_aura_visible: bool = false
@export var leaves_trail: bool = false
@export var trail_damage: int = 3
@export var trail_radius: float = 28.0
@export var trail_duration: float = 2.4
@export var trail_tick_interval: float = 0.45
@export var trail_spawn_interval: float = 0.35
@export var trail_color: Color = Color(0.55, 0.95, 0.28, 0.42)
@export var outline_color: Color = Color(0.18, 0.02, 0.02)
@export var body_color: Color = Color(0.9, 0.22, 0.2)
@export var eye_color: Color = Color(0.08, 0.01, 0.01)
@export var hit_flash_color: Color = Color(1.0, 0.95, 0.72)
@export var uses_drop_intro: bool = false
@export var uses_spawn_telegraph: bool = false
@export var spawn_telegraph_flashes: int = 3
@export var spawn_telegraph_flash_time: float = 0.18
@export var spawn_telegraph_gap_time: float = 0.14
@export var spawn_warning_color: Color = Color(1.0, 0.78, 0.18, 0.8)
@export var drop_height: float = 92.0
@export var drop_time: float = 0.28
@export var post_drop_wait_time: float = 0.35

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
var _projectile_timer: float = 0.0
var _area_timer: float = 0.0
var _area_windup_timer: float = 0.0
var _area_target_position: Vector2 = Vector2.ZERO
var _area_is_telegraphing: bool = false
var _trail_timer: float = 0.0
var _spawn_intro_active: bool = false


func setup(target_player: Node2D) -> void:
	# O Game injeta a referencia do jogador quando cria o inimigo.
	player = target_player


func can_be_targeted() -> bool:
	return not _spawn_intro_active


func _ready() -> void:
	current_health = max_health
	_strafe_sign = -1.0 if randf() < 0.5 else 1.0
	add_to_group("enemies")
	_update_visual()
	if uses_spawn_telegraph:
		_begin_spawn_telegraph()
	else:
		_play_drop_intro_if_needed()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	if _spawn_intro_active:
		return

	# Cada cena escolhe um modo de movimento simples pelo Inspector.
	velocity = _get_velocity_for_movement_mode(delta)
	move_and_slide()
	_update_projectile_attack(delta)
	_update_area_attack(delta)
	_update_trail(delta)

	if _hit_flash_time > 0.0:
		_hit_flash_time -= delta
		_update_visual()


func _update_area_attack(delta: float) -> void:
	if not uses_area_attack:
		return

	# Area attack tem aviso antes do dano quando area_windup_time > 0.
	if _area_is_telegraphing:
		_area_windup_timer = maxf(_area_windup_timer - delta, 0.0)
		_update_area_warning_feedback()
		if _area_windup_timer == 0.0:
			_finish_area_attack()
		return

	_area_timer = maxf(_area_timer - delta, 0.0)
	if _area_timer > 0.0:
		return

	if area_target_mode == "self" and global_position.distance_to(player.global_position) > area_range:
		return

	_begin_area_telegraph()


func _update_projectile_attack(delta: float) -> void:
	if not shoots_projectiles:
		return

	_projectile_timer = maxf(_projectile_timer - delta, 0.0)
	if _projectile_timer > 0.0:
		return

	var distance_to_player: float = global_position.distance_to(player.global_position)
	if distance_to_player > projectile_range:
		return

	projectile_requested.emit(global_position, player.global_position, projectile_damage, projectile_speed, projectile_color)
	_projectile_timer = projectile_interval


func _update_trail(delta: float) -> void:
	if not leaves_trail:
		return

	# O inimigo so pede para o Game criar o rastro; o Game decide onde instanciar efeitos globais.
	_trail_timer = maxf(_trail_timer - delta, 0.0)
	if _trail_timer > 0.0:
		return

	trail_requested.emit(global_position, "player", trail_damage, trail_radius, trail_duration, trail_tick_interval, trail_color)
	_trail_timer = trail_spawn_interval


func _get_velocity_for_movement_mode(delta: float) -> Vector2:
	match movement_mode:
		"charger":
			return _get_charger_velocity(delta)
		"skirmisher":
			return _get_directional_velocity(_get_skirmisher_direction())
		"stationary":
			return Vector2.ZERO
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
			_hide_dash_warning()
		return _dash_direction * dash_speed

	if _is_winding_up_dash:
		_dash_windup_timer = maxf(_dash_windup_timer - delta, 0.0)
		_update_dash_warning_feedback()
		if _dash_windup_timer == 0.0:
			_is_winding_up_dash = false
			_dash_timer = dash_duration
		return Vector2.ZERO

	if _dash_cooldown_timer > 0.0:
		_dash_cooldown_timer = maxf(_dash_cooldown_timer - delta, 0.0)
		return _get_chase_direction() * speed * 0.45

	var distance_to_player: float = global_position.distance_to(player.global_position)
	if distance_to_player <= dash_trigger_range:
		_is_winding_up_dash = true
		_dash_windup_timer = dash_windup_time
		_dash_direction = _get_chase_direction()
		if _dash_direction == Vector2.ZERO:
			_dash_direction = Vector2.RIGHT
		_show_dash_warning()
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


func take_damage(amount: int, attack_type: String = "direct") -> int:
	if current_health <= 0 or not can_be_targeted():
		return 0

	# Retornar o dano real ajuda o HUD/feedback a mostrar resistencia, bloqueio ou imunidade sem mentir.
	var final_amount: int = amount
	if attack_type == "ranged":
		final_amount = int(roundf(float(amount) * ranged_damage_multiplier))

	if final_amount <= 0:
		_show_resist_feedback()
		return 0

	# O flash visual confirma que o inimigo recebeu dano mesmo sem sprite/animacao.
	current_health -= final_amount
	_hit_flash_time = 0.08
	_update_visual()

	if current_health <= 0:
		died.emit(self)
		queue_free()

	return final_amount


func _update_visual() -> void:
	# Cada cena concreta define suas cores; o script so aplica feedback de dano.
	var visible_body_color: Color = body_color
	if _hit_flash_time > 0.0:
		visible_body_color = hit_flash_color

	outline_visual.color = outline_color
	body_visual.color = visible_body_color
	left_eye_visual.color = eye_color
	right_eye_visual.color = eye_color


func _show_dash_warning() -> void:
	var warning_line: Line2D = get_node_or_null("DashWarning") as Line2D
	if not warning_line:
		return

	warning_line.visible = true
	warning_line.width = dash_warning_width
	warning_line.default_color = dash_warning_color
	_update_dash_warning_feedback()


func _update_dash_warning_feedback() -> void:
	var warning_line: Line2D = get_node_or_null("DashWarning") as Line2D
	if not warning_line:
		return

	var warning_length: float = dash_speed * dash_duration + contact_range
	var progress: float = 1.0 - (_dash_windup_timer / maxf(dash_windup_time, 0.001))
	var warning_color: Color = dash_warning_color
	warning_color.a = lerpf(0.3, dash_warning_color.a, progress)

	WARNING_VISUALS.configure_dash_warning(
		warning_line,
		global_position,
		_dash_direction,
		warning_length,
		dash_warning_width,
		warning_color
	)


func _hide_dash_warning() -> void:
	var warning_line: Line2D = get_node_or_null("DashWarning") as Line2D
	if not warning_line:
		return

	WARNING_VISUALS.hide_dash_warning(warning_line)


func _begin_area_telegraph() -> void:
	if area_target_mode == "player_position":
		_area_target_position = player.global_position
	else:
		_area_target_position = global_position

	if area_windup_time <= 0.0:
		_finish_area_attack()
		return

	_area_is_telegraphing = true
	_area_windup_timer = area_windup_time
	_show_area_warning_feedback()


func _finish_area_attack() -> void:
	_area_is_telegraphing = false
	_area_timer = area_interval
	_show_pulse_feedback(_area_target_position)

	if player.global_position.distance_to(_area_target_position) > area_range:
		return

	player.call("take_damage", area_damage)
	area_attack_used.emit(player.global_position, area_damage)


func _begin_spawn_telegraph() -> void:
	# O totem anuncia a regiao onde vai cair antes de virar uma fonte de aura.
	_spawn_intro_active = true
	_set_body_visual_visible(false)

	var warning_node: Node2D = _get_spawn_warning_node()
	if not warning_node:
		_finish_spawn_intro_after_wait()
		return

	warning_node.visible = true
	warning_node.global_position = global_position
	warning_node.scale = Vector2.ONE * 0.92
	warning_node.modulate.a = 0.15
	WARNING_VISUALS.set_area_node_color(warning_node, spawn_warning_color)

	var tween: Tween = create_tween()
	for _flash_index in range(spawn_telegraph_flashes):
		tween.tween_property(warning_node, "modulate:a", 0.95, spawn_telegraph_flash_time)
		tween.parallel().tween_property(warning_node, "scale", Vector2.ONE * 1.05, spawn_telegraph_flash_time)
		tween.tween_property(warning_node, "modulate:a", 0.18, spawn_telegraph_gap_time)
		tween.parallel().tween_property(warning_node, "scale", Vector2.ONE * 0.92, spawn_telegraph_gap_time)

	tween.tween_callback(_drop_after_spawn_telegraph)


func _drop_after_spawn_telegraph() -> void:
	var warning_node: Node2D = _get_spawn_warning_node()
	if warning_node:
		warning_node.visible = false
		warning_node.modulate.a = 1.0
		warning_node.scale = Vector2.ONE
		warning_node.position = Vector2.ZERO

	_set_body_visual_visible(true)
	_play_drop_intro_if_needed(_finish_spawn_intro_after_wait)


func _finish_spawn_intro_after_wait() -> void:
	if post_drop_wait_time <= 0.0:
		_spawn_intro_active = false
		_show_idle_area_aura()
		return

	var tween: Tween = create_tween()
	tween.tween_interval(post_drop_wait_time)
	tween.tween_callback(func() -> void:
		_spawn_intro_active = false
		_show_idle_area_aura()
	)


func _show_idle_area_aura() -> void:
	if not keeps_area_aura_visible:
		return

	var aura_node: Node2D = _get_area_aura_node()
	if not aura_node:
		return

	aura_node.visible = true
	aura_node.global_position = global_position
	aura_node.scale = Vector2.ONE
	aura_node.modulate.a = 1.0
	WARNING_VISUALS.set_area_node_color(aura_node, area_aura_color)


func _show_area_warning_feedback() -> void:
	var warning_node: Node2D = _get_spawn_warning_node()
	if not warning_node:
		return

	warning_node.visible = true
	warning_node.modulate.a = 1.0
	warning_node.global_position = _area_target_position
	warning_node.scale = Vector2.ONE * 0.9
	WARNING_VISUALS.set_area_node_color(warning_node, area_warning_color)


func _update_area_warning_feedback() -> void:
	var warning_node: Node2D = _get_spawn_warning_node()
	if not warning_node:
		return

	var progress: float = 1.0 - (_area_windup_timer / maxf(area_windup_time, 0.001))
	warning_node.global_position = _area_target_position
	warning_node.scale = Vector2.ONE * lerpf(0.9, 1.08, progress)
	warning_node.modulate.a = lerpf(0.45, 0.85, progress)


func _show_pulse_feedback(world_position: Vector2) -> void:
	var aura_node: Node2D = _get_area_aura_node()
	if not aura_node:
		return

	aura_node.visible = true
	aura_node.modulate.a = 1.0
	aura_node.global_position = world_position
	aura_node.scale = Vector2.ONE * 1.08
	WARNING_VISUALS.set_area_node_color(aura_node, area_feedback_color)

	var tween: Tween = create_tween()
	tween.tween_property(aura_node, "scale", Vector2.ONE * 1.22, 0.16)
	tween.parallel().tween_property(aura_node, "modulate:a", 0.0, 0.24)
	if keeps_area_aura_visible:
		tween.tween_callback(_show_idle_area_aura)
	else:
		tween.tween_callback(_hide_pulse_feedback.bind(aura_node))


func _hide_pulse_feedback(pulse_node: Node2D) -> void:
	if not is_instance_valid(pulse_node):
		return

	pulse_node.visible = false
	pulse_node.modulate.a = 1.0
	pulse_node.scale = Vector2.ONE
	pulse_node.position = Vector2.ZERO


func _get_area_aura_node() -> Node2D:
	var aura_node: Node2D = get_node_or_null("Visual/AreaAura") as Node2D
	if aura_node:
		return aura_node

	return get_node_or_null("Visual/Pulse") as Node2D


func _get_spawn_warning_node() -> Node2D:
	var warning_node: Node2D = get_node_or_null("Visual/SpawnWarning") as Node2D
	if warning_node:
		return warning_node

	return get_node_or_null("Visual/Pulse") as Node2D


func _set_body_visual_visible(is_visible: bool) -> void:
	outline_visual.visible = is_visible
	body_visual.visible = is_visible
	left_eye_visual.visible = is_visible
	right_eye_visual.visible = is_visible


func _show_resist_feedback() -> void:
	var visual_node: Node2D = get_node_or_null("Visual") as Node2D
	if not visual_node:
		return

	var tween: Tween = create_tween()
	tween.tween_property(visual_node, "scale", Vector2.ONE * 1.18, 0.05)
	tween.tween_property(visual_node, "scale", Vector2.ONE, 0.1)


func _play_drop_intro_if_needed(finished_callback: Callable = Callable()) -> void:
	if not uses_drop_intro:
		if finished_callback.is_valid():
			finished_callback.call()
		return

	var visual_node: Node2D = get_node_or_null("Visual") as Node2D
	if not visual_node:
		if finished_callback.is_valid():
			finished_callback.call()
		return

	visual_node.position = Vector2(0.0, -drop_height)
	visual_node.modulate.a = 0.25
	var tween: Tween = create_tween()
	tween.tween_property(visual_node, "position:y", 0.0, drop_time)
	tween.parallel().tween_property(visual_node, "modulate:a", 1.0, drop_time)
	if finished_callback.is_valid():
		tween.tween_callback(finished_callback)
