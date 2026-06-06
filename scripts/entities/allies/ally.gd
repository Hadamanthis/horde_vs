extends CharacterBody2D
class_name Ally

const WARNING_VISUALS = preload("res://scripts/effects/warning_visuals.gd")

@export var orbit_radius: float = 58.0
@export var orbit_speed: float = 1.45
@export var move_speed: float = 260.0
@export var attack_damage: int = 6
@export var attack_range: float = 34.0
@export var attack_interval: float = 0.45
@export var ally_type: String = "slime"
@export var attack_mode: String = "melee"
@export var melee_arc_max_targets: int = 8
@export var attack_command_radius: float = 9999.0
@export var pursuit_hit_radius: float = 24.0
@export var pursuit_duration: float = 0.9
@export var pursuit_chain_count: int = 0
@export var pursuit_chain_range: float = 96.0
@export var pursuit_chain_damage_multiplier: float = 0.65
@export var projectile_speed: float = 360.0
@export var projectile_color: Color = Color(0.58, 1.0, 0.95)
@export var projectile_spread_count: int = 1
@export var projectile_spread_angle_degrees: float = 16.0
@export var attack_dash_speed: float = 360.0
@export var attack_dash_windup_time: float = 0.18
@export var attack_dash_duration: float = 0.24
@export var attack_dash_hit_radius: float = 24.0
@export var attack_dash_warning_width: float = 32.0
@export var attack_dash_warning_color: Color = Color(0.46, 1.0, 0.82, 0.42)
@export var dash_leaves_trail_during_attack: bool = false
@export var dash_trail_spawn_interval: float = 0.08
@export var stationary_duration: float = 4.0
@export var stationary_cooldown: float = 3.5
@export var stationary_min_distance: float = 120.0
@export var stationary_max_distance: float = 190.0
@export var stationary_windup_time: float = 0.75
@export var stationary_drop_height: float = 86.0
@export var stationary_drop_time: float = 0.25
@export var stationary_warning_color: Color = Color(1.0, 0.82, 0.24, 0.72)
@export var stationary_aura_color: Color = Color(0.46, 1.0, 0.82, 0.28)
@export var trail_damage: int = 3
@export var trail_radius: float = 28.0
@export var trail_duration: float = 2.4
@export var trail_tick_interval: float = 0.45
@export var trail_spawn_interval: float = 0.38
@export var trail_color: Color = Color(0.52, 1.0, 0.44, 0.42)
@export var shield_block_radius: float = 34.0
@export var shield_push_radius: float = 58.0
@export var shield_push_distance: float = 16.0
@export var shield_push_interval: float = 0.18
@export var shield_push_shows_barrier_feedback: bool = false
@export var attack_flash_time: float = 0.12
@export_range(1, 3, 1) var ally_level: int = 1

@onready var visual: Node2D = $Visual as Node2D
@onready var sprite_visual: Sprite2D = get_node_or_null("Visual/Sprite2D") as Sprite2D

var player: Node2D
var game: Node
var slot_index: int = 0
var slot_count: int = 1

var _attack_timer: float = 0.0
var _attack_flash_timer: float = 0.0
var _orbit_time: float = 0.0
var _dash_windup_timer: float = 0.0
var _dash_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _dash_hit_enemies: Array[Enemy] = []
var _pursuit_target: Enemy = null
var _pursuit_timer: float = 0.0
var _stationary_is_active: bool = false
var _stationary_is_telegraphing: bool = false
var _stationary_duration_timer: float = 0.0
var _stationary_cooldown_timer: float = 0.0
var _stationary_windup_timer: float = 0.0
var _trail_timer: float = 0.0
var _shield_push_timer: float = 0.0
var _dash_trail_timer: float = 0.0
var _base_attack_damage: int = 0
var _base_attack_interval: float = 0.0
var _base_stationary_cooldown: float = 0.0
var _base_stationary_duration: float = 0.0
var _base_trail_duration: float = 0.0
var _base_shield_block_radius: float = 0.0
var _base_stats_ready: bool = false
var _level_visual_scale: float = 1.0
var _sprite_border_visual: Sprite2D
var _ally_ring_visual: Line2D
var _ally_marker_visual: Polygon2D


func setup(target_player: Node2D, game_node: Node, index: int, count: int, level: int = 1) -> void:
	player = target_player
	game = game_node
	slot_index = index
	slot_count = maxi(count, 1)
	set_ally_level(level)


func update_orbit_slot(index: int, count: int) -> void:
	slot_index = index
	slot_count = maxi(count, 1)


func _ready() -> void:
	add_to_group("allies")
	_ensure_sprite_border()
	_ensure_ally_identity_visuals()
	_capture_base_stats()
	set_ally_level(ally_level)
	if attack_mode == "stationary_aura":
		visible = false
		_stationary_cooldown_timer = 0.0


func set_ally_level(level: int) -> void:
	ally_level = clampi(level, 1, 3)
	_level_visual_scale = 1.0 + float(ally_level - 1) * 0.18

	match ally_level:
		2:
			visual.modulate = Color(1.18, 1.1, 1.0, 1.0)
		3:
			visual.modulate = Color(1.0, 1.22, 1.35, 1.0)
		_:
			visual.modulate = Color.WHITE

	_set_visual_scale(1.0)
	_ensure_sprite_border()
	_ensure_ally_identity_visuals()


func apply_horde_bonuses(flat_damage_bonus: int, same_type_damage_bonus: float, cooldown_multiplier: float, effect_duration_multiplier: float) -> void:
	# O Game recalcula bonus globais quando a composicao muda; aqui restauramos a base antes de aplicar tudo.
	_capture_base_stats()
	var level_damage_bonus: float = float(ally_level - 1) * 0.35
	var damage_multiplier: float = 1.0 + same_type_damage_bonus + level_damage_bonus
	attack_damage = maxi(1, int(round(float(_base_attack_damage + flat_damage_bonus) * damage_multiplier)))
	var level_cooldown_multiplier: float = 1.0 - float(ally_level - 1) * 0.08
	attack_interval = maxf(_base_attack_interval * cooldown_multiplier * level_cooldown_multiplier, 0.08)
	stationary_cooldown = maxf(_base_stationary_cooldown * cooldown_multiplier, 0.1)
	stationary_duration = _base_stationary_duration * effect_duration_multiplier
	trail_duration = _base_trail_duration * effect_duration_multiplier
	shield_block_radius = _base_shield_block_radius * effect_duration_multiplier


func _capture_base_stats() -> void:
	if _base_stats_ready:
		return

	_base_attack_damage = attack_damage
	_base_attack_interval = attack_interval
	_base_stationary_cooldown = stationary_cooldown
	_base_stationary_duration = stationary_duration
	_base_trail_duration = trail_duration
	_base_shield_block_radius = shield_block_radius
	_base_stats_ready = true


func _set_visual_scale(multiplier: float) -> void:
	if not is_node_ready():
		return

	visual.scale = Vector2.ONE * _level_visual_scale * multiplier


func _ensure_sprite_border() -> void:
	if not is_instance_valid(sprite_visual):
		return

	_sprite_border_visual = get_node_or_null("Visual/AllyBorder") as Sprite2D
	if not is_instance_valid(_sprite_border_visual):
		_sprite_border_visual = Sprite2D.new()
		_sprite_border_visual.name = "AllyBorder"
		visual.add_child(_sprite_border_visual)
		visual.move_child(_sprite_border_visual, sprite_visual.get_index())

	_sprite_border_visual.texture = sprite_visual.texture
	_sprite_border_visual.region_enabled = sprite_visual.region_enabled
	_sprite_border_visual.region_rect = sprite_visual.region_rect
	_sprite_border_visual.centered = sprite_visual.centered
	_sprite_border_visual.offset = sprite_visual.offset
	_sprite_border_visual.position = sprite_visual.position
	_sprite_border_visual.rotation = sprite_visual.rotation
	_sprite_border_visual.scale = sprite_visual.scale * 1.18
	_sprite_border_visual.flip_h = sprite_visual.flip_h
	_sprite_border_visual.flip_v = sprite_visual.flip_v
	_sprite_border_visual.z_index = sprite_visual.z_index - 1
	_sprite_border_visual.modulate = Color(0.0, 1.0, 0.86, 1.0)


func _ensure_ally_identity_visuals() -> void:
	if not is_instance_valid(visual):
		return

	_ally_ring_visual = get_node_or_null("Visual/AllyRing") as Line2D
	if not is_instance_valid(_ally_ring_visual):
		_ally_ring_visual = Line2D.new()
		_ally_ring_visual.name = "AllyRing"
		visual.add_child(_ally_ring_visual)
		visual.move_child(_ally_ring_visual, 0)

	_ally_ring_visual.closed = true
	_ally_ring_visual.width = 4.0
	_ally_ring_visual.default_color = Color(0.0, 1.0, 0.88, 0.95)
	_ally_ring_visual.z_index = -6
	_ally_ring_visual.points = _make_circle_points(25.0 + float(ally_level - 1) * 3.0, 24)

	_ally_marker_visual = get_node_or_null("Visual/AllyMarker") as Polygon2D
	if not is_instance_valid(_ally_marker_visual):
		_ally_marker_visual = Polygon2D.new()
		_ally_marker_visual.name = "AllyMarker"
		visual.add_child(_ally_marker_visual)

	_ally_marker_visual.position = Vector2(0.0, -35.0 - float(ally_level - 1) * 4.0)
	_ally_marker_visual.z_index = 8
	_ally_marker_visual.color = Color(1.0, 0.9, 0.22, 0.95)
	_ally_marker_visual.polygon = PackedVector2Array([
		Vector2(0.0, -7.0),
		Vector2(7.0, 0.0),
		Vector2(0.0, 7.0),
		Vector2(-7.0, 0.0),
	])


func _make_circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index in range(segments):
		var angle: float = TAU * float(index) / float(segments)
		points.append(Vector2.RIGHT.rotated(angle) * radius)

	return points


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_orbit_time += delta * orbit_speed
	_attack_timer = maxf(_attack_timer - delta, 0.0)

	if attack_mode == "stationary_aura":
		_process_stationary_aura(delta)
		return

	if _dash_windup_timer > 0.0:
		_process_dash_windup(delta)
		return

	if _dash_timer > 0.0:
		_process_dash(delta)
		return

	if is_instance_valid(_pursuit_target):
		_process_pursuit_attack(delta)
		return

	if attack_mode == "pursuit" and _attack_timer == 0.0 and _is_inside_command_radius():
		var pursuit_enemy: Enemy = _find_nearest_enemy()
		if pursuit_enemy:
			_begin_pursuit_attack(pursuit_enemy)
			_process_pursuit_attack(delta)
			return

	# A orbita evita IA complexa e deixa a horda facil de ler ao redor do jogador.
	var ring: int = floori(float(slot_index) / 10.0)
	var members_in_ring: int = mini(slot_count - ring * 10, 10)
	var local_index: int = slot_index - ring * 10
	var angle_step: float = TAU / maxf(float(members_in_ring), 1.0)
	var angle: float = local_index * angle_step + _orbit_time + ring * 0.55
	var desired_position: Vector2 = player.global_position + Vector2.RIGHT.rotated(angle) * (orbit_radius + ring * 28.0)

	velocity = (desired_position - global_position) * 6.0
	velocity = velocity.limit_length(move_speed)
	move_and_slide()
	_update_sprite_facing(velocity)

	if attack_mode == "trail":
		_update_trail(delta)

	if attack_mode == "shield":
		_update_shield_push(delta)

	if _attack_timer == 0.0:
		_try_attack()

	_update_attack_feedback(delta)


func _process_stationary_aura(delta: float) -> void:
	# Totens convertidos viram uma peca de territorio: aparecem, pulsam e somem.
	if not _stationary_is_active:
		_stationary_cooldown_timer = maxf(_stationary_cooldown_timer - delta, 0.0)
		if _stationary_cooldown_timer == 0.0:
			_deploy_stationary_aura()
		return

	_stationary_duration_timer = maxf(_stationary_duration_timer - delta, 0.0)
	velocity = Vector2.ZERO
	move_and_slide()

	if _stationary_is_telegraphing:
		_update_stationary_aura_warning()
		_stationary_windup_timer = maxf(_stationary_windup_timer - delta, 0.0)
		if _stationary_windup_timer == 0.0:
			_activate_stationary_aura()
		return

	if _attack_timer == 0.0:
		_try_aura_attack()

	_update_attack_feedback(delta)

	if _stationary_duration_timer == 0.0:
		_recall_stationary_aura()


func _deploy_stationary_aura() -> void:
	var angle: float = randf() * TAU
	var distance: float = randf_range(stationary_min_distance, stationary_max_distance)
	global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
	_stationary_is_active = true
	_stationary_is_telegraphing = true
	_stationary_windup_timer = stationary_windup_time
	_stationary_duration_timer = stationary_duration
	_attack_timer = attack_interval
	visible = true
	set_physics_process(true)
	_play_stationary_drop_intro()
	_show_stationary_aura_warning()


func _activate_stationary_aura() -> void:
	_stationary_is_telegraphing = false
	_stationary_duration_timer = stationary_duration
	_attack_timer = 0.0
	_hide_stationary_warning_feedback()
	_show_stationary_active_aura()


func _recall_stationary_aura() -> void:
	_stationary_is_active = false
	_stationary_is_telegraphing = false
	_stationary_cooldown_timer = stationary_cooldown
	visible = false
	_hide_stationary_aura_feedback()


func _process_dash_windup(delta: float) -> void:
	# O windup cria antecipacao visual: o aliado vai atacar, mas ainda nao causou dano.
	_dash_windup_timer = maxf(_dash_windup_timer - delta, 0.0)
	velocity = Vector2.ZERO
	move_and_slide()
	_set_visual_scale(1.15)
	_update_dash_warning_feedback()

	if _dash_windup_timer == 0.0:
		_dash_timer = attack_dash_duration


func _process_dash(delta: float) -> void:
	# Durante a investida, o aliado atravessa o campo e acerta tudo perto do caminho.
	_dash_timer = maxf(_dash_timer - delta, 0.0)
	velocity = _dash_direction * attack_dash_speed
	move_and_slide()
	_update_sprite_facing(_dash_direction)
	_update_dash_trail(delta)
	_damage_enemies_during_dash()
	_set_visual_scale(1.32)

	if _dash_timer == 0.0:
		_dash_hit_enemies.clear()
		_attack_timer = attack_interval
		_hide_dash_warning()


func _begin_pursuit_attack(enemy: Enemy) -> void:
	_pursuit_target = enemy
	_pursuit_timer = pursuit_duration


func _process_pursuit_attack(delta: float) -> void:
	# O bat aliado preserva a fantasia de criatura rapida: sai da orbita, morde e volta.
	if not is_instance_valid(_pursuit_target):
		_end_pursuit_attack(true)
		return

	_pursuit_timer = maxf(_pursuit_timer - delta, 0.0)
	if _pursuit_timer == 0.0 or not _is_inside_command_radius():
		_end_pursuit_attack(true)
		return

	var to_enemy: Vector2 = _pursuit_target.global_position - global_position
	if to_enemy.length() <= pursuit_hit_radius:
		_pursuit_target.take_damage(attack_damage, "melee")
		_spawn_damage_feedback_amount(attack_damage, _pursuit_target.global_position)
		_damage_pursuit_chain(_pursuit_target)
		_end_pursuit_attack(false)
		_update_attack_feedback(delta)
		return

	velocity = to_enemy.normalized() * move_speed
	move_and_slide()
	_update_sprite_facing(to_enemy)
	_set_visual_scale(1.12)


func _end_pursuit_attack(use_short_cooldown: bool) -> void:
	_pursuit_target = null
	if use_short_cooldown:
		_attack_timer = attack_interval * 0.45
	else:
		_start_attack_cooldown()


func _update_attack_feedback(delta: float) -> void:
	if _attack_flash_timer > 0.0:
		_attack_flash_timer = maxf(_attack_flash_timer - delta, 0.0)
		_set_visual_scale(1.25)
	else:
		_set_visual_scale(1.0)


func _find_nearest_enemy() -> Enemy:
	if not is_instance_valid(game) or not game.has_method("get_nearest_enemy"):
		return null

	return game.call("get_nearest_enemy", global_position, attack_range) as Enemy


func _try_attack() -> void:
	if not _is_inside_command_radius():
		return

	match attack_mode:
		"aura":
			_try_aura_attack()
		"dash":
			_try_single_target_attack(true)
		"melee_arc":
			_try_melee_arc_attack()
		"pursuit":
			return
		"shooter":
			_try_projectile_attack()
		"trail":
			return
		"shield":
			return
		_:
			_try_single_target_attack(false)


func _try_single_target_attack(should_lunge: bool) -> void:
	# Ataque de alvo unico: simples, legivel e bom para aliados comuns.
	var enemy: Enemy = _find_nearest_enemy()
	if not enemy or global_position.distance_to(enemy.global_position) > attack_range:
		return

	if should_lunge:
		_begin_dash_attack(enemy)
		return

	_update_sprite_facing(enemy.global_position - global_position)
	enemy.take_damage(attack_damage, "melee")
	_spawn_damage_feedback_amount(attack_damage, enemy.global_position)
	_start_attack_cooldown()


func _try_melee_arc_attack() -> void:
	var enemies_hit: int = _damage_enemies_in_radius(global_position, attack_range, attack_damage, "melee", melee_arc_max_targets)
	if enemies_hit == 0:
		return

	_show_pulse_feedback()
	_start_attack_cooldown()


func _try_aura_attack() -> void:
	# Aura bate em varios inimigos proximos; ideal para aliado raro de controle de grupo.
	var hit_any_enemy: bool = false
	var nearby_nodes: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for nearby_node in nearby_nodes:
		var enemy: Enemy = nearby_node as Enemy
		if not is_instance_valid(enemy):
			continue

		if global_position.distance_to(enemy.global_position) <= attack_range:
			enemy.take_damage(attack_damage, "area")
			_spawn_damage_feedback_amount(attack_damage, enemy.global_position)
			hit_any_enemy = true

	if hit_any_enemy:
		if attack_mode == "stationary_aura":
			_flash_stationary_aura_feedback()
		else:
			_show_pulse_feedback()
		_start_attack_cooldown()


func _try_projectile_attack() -> void:
	# Atiradores aliados mantem a formacao e contribuem de longe.
	var enemy: Enemy = _find_nearest_enemy()
	if not enemy or global_position.distance_to(enemy.global_position) > attack_range:
		return

	_update_sprite_facing(enemy.global_position - global_position)
	if is_instance_valid(game) and game.has_method("spawn_ally_projectile"):
		_spawn_projectile_spread(enemy.global_position)
	_start_attack_cooldown()


func _spawn_projectile_spread(target_position: Vector2) -> void:
	var shot_count: int = maxi(projectile_spread_count, 1)
	var base_direction: Vector2 = (target_position - global_position).normalized()
	if base_direction == Vector2.ZERO:
		base_direction = Vector2.RIGHT

	var spread_angle: float = deg_to_rad(projectile_spread_angle_degrees)
	var center_offset: float = float(shot_count - 1) * 0.5
	for index in range(shot_count):
		var angle_offset: float = (float(index) - center_offset) * spread_angle
		var shot_direction: Vector2 = base_direction.rotated(angle_offset)
		var spread_target: Vector2 = global_position + shot_direction * attack_range
		game.call("spawn_ally_projectile", global_position, spread_target, attack_damage, projectile_speed, projectile_color)


func _update_sprite_facing(direction: Vector2) -> void:
	if not is_instance_valid(sprite_visual) or absf(direction.x) <= 0.05:
		return

	var should_flip: bool = direction.x < 0.0
	sprite_visual.flip_h = should_flip
	if is_instance_valid(_sprite_border_visual):
		_sprite_border_visual.flip_h = should_flip


func _show_pulse_feedback() -> void:
	var pulse_node: Node2D = _get_or_create_pulse_node()
	if not pulse_node:
		return

	pulse_node.visible = true
	pulse_node.scale = Vector2.ONE * 1.35
	WARNING_VISUALS.set_area_node_color(pulse_node, Color(0.46, 1.0, 0.82, 0.45))

	var tween: Tween = create_tween()
	tween.tween_property(pulse_node, "scale", Vector2.ONE * 0.2, attack_flash_time)
	tween.parallel().tween_property(pulse_node, "modulate:a", 0.0, attack_flash_time)
	tween.tween_callback(_hide_pulse_feedback.bind(pulse_node))


func _get_or_create_pulse_node() -> Node2D:
	var pulse_node: Node2D = get_node_or_null("Visual/Pulse") as Node2D
	if pulse_node:
		return pulse_node
	if not is_instance_valid(visual):
		return null

	pulse_node = Node2D.new()
	pulse_node.name = "Pulse"
	pulse_node.visible = false
	visual.add_child(pulse_node)

	var fill: Polygon2D = Polygon2D.new()
	fill.name = "Fill"
	fill.polygon = _make_circle_polygon(32.0)
	fill.color = Color(0.46, 1.0, 0.82, 0.2)
	pulse_node.add_child(fill)

	var ring: Polygon2D = Polygon2D.new()
	ring.name = "Ring"
	ring.polygon = _make_circle_polygon(35.0)
	ring.color = Color(0.46, 1.0, 0.82, 0.45)
	pulse_node.add_child(ring)

	return pulse_node


func _make_circle_polygon(radius: float, point_count: int = 24) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index in range(point_count):
		var angle: float = TAU * float(index) / float(point_count)
		points.append(Vector2.RIGHT.rotated(angle) * radius)

	return points


func _hide_pulse_feedback(pulse_node: Node2D) -> void:
	if not is_instance_valid(pulse_node):
		return

	pulse_node.visible = false
	pulse_node.modulate.a = 1.0
	pulse_node.scale = Vector2.ONE


func _show_stationary_aura_warning() -> void:
	var warning_node: Node2D = _get_stationary_warning_node()
	if not warning_node:
		return

	warning_node.visible = true
	warning_node.global_position = global_position
	warning_node.scale = Vector2.ONE * 0.92
	warning_node.modulate.a = 0.45
	WARNING_VISUALS.set_area_node_color(warning_node, stationary_warning_color)


func _update_stationary_aura_warning() -> void:
	var warning_node: Node2D = _get_stationary_warning_node()
	if not warning_node:
		return

	var progress: float = 1.0 - (_stationary_windup_timer / maxf(stationary_windup_time, 0.001))
	warning_node.global_position = global_position
	warning_node.scale = Vector2.ONE * lerpf(0.85, 1.08, progress)
	warning_node.modulate.a = lerpf(0.35, 0.78, progress)


func _flash_stationary_aura_feedback() -> void:
	var aura_node: Node2D = _get_stationary_aura_node()
	if not aura_node:
		return

	aura_node.visible = true
	aura_node.global_position = global_position
	aura_node.modulate.a = 1.0
	aura_node.scale = Vector2.ONE * 1.08
	WARNING_VISUALS.set_area_node_color(aura_node, Color(stationary_aura_color.r, stationary_aura_color.g, stationary_aura_color.b, 0.62))

	var tween: Tween = create_tween()
	tween.tween_property(aura_node, "scale", Vector2.ONE * 1.18, attack_flash_time)
	tween.parallel().tween_property(aura_node, "modulate:a", 0.55, attack_flash_time)
	tween.tween_callback(_show_stationary_active_aura)


func _hide_stationary_aura_feedback() -> void:
	_hide_stationary_warning_feedback()

	var aura_node: Node2D = _get_stationary_aura_node()
	if aura_node:
		aura_node.visible = false
		aura_node.modulate.a = 1.0
		aura_node.scale = Vector2.ONE
		aura_node.position = Vector2.ZERO


func _hide_stationary_warning_feedback() -> void:
	var warning_node: Node2D = _get_stationary_warning_node()
	if not warning_node:
		return

	warning_node.visible = false
	warning_node.modulate.a = 1.0
	warning_node.scale = Vector2.ONE
	warning_node.position = Vector2.ZERO


func _show_stationary_active_aura() -> void:
	var aura_node: Node2D = _get_stationary_aura_node()
	if not aura_node:
		return

	aura_node.visible = true
	aura_node.global_position = global_position
	aura_node.scale = Vector2.ONE
	aura_node.modulate.a = 1.0
	WARNING_VISUALS.set_area_node_color(aura_node, stationary_aura_color)


func _get_stationary_warning_node() -> Node2D:
	var warning_node: Node2D = get_node_or_null("Visual/SpawnWarning") as Node2D
	if warning_node:
		return warning_node

	return get_node_or_null("Visual/Pulse") as Node2D


func _get_stationary_aura_node() -> Node2D:
	var aura_node: Node2D = get_node_or_null("Visual/AreaAura") as Node2D
	if aura_node:
		return aura_node

	return get_node_or_null("Visual/Pulse") as Node2D


func _play_stationary_drop_intro() -> void:
	visual.position.y = -stationary_drop_height
	visual.modulate.a = 0.25
	var tween: Tween = create_tween()
	tween.tween_property(visual, "position:y", 0.0, stationary_drop_time)
	tween.parallel().tween_property(visual, "modulate:a", 1.0, stationary_drop_time)


func _begin_dash_attack(enemy: Enemy) -> void:
	# O javali aliado herda a personalidade de inimigo: mira, prepara e investe.
	_dash_direction = (enemy.global_position - global_position).normalized()
	if _dash_direction == Vector2.ZERO:
		_dash_direction = Vector2.RIGHT

	_update_sprite_facing(_dash_direction)
	_dash_hit_enemies.clear()
	_dash_windup_timer = attack_dash_windup_time
	_attack_flash_timer = attack_flash_time
	_show_dash_warning()


func _damage_enemies_during_dash() -> void:
	var nearby_nodes: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for nearby_node in nearby_nodes:
		var enemy: Enemy = nearby_node as Enemy
		if not is_instance_valid(enemy) or _dash_hit_enemies.has(enemy):
			continue

		if global_position.distance_to(enemy.global_position) <= attack_dash_hit_radius:
			enemy.take_damage(attack_damage, "melee")
			_dash_hit_enemies.append(enemy)
			_spawn_damage_feedback_amount(attack_damage, enemy.global_position)


func _show_dash_warning() -> void:
	var warning_line: Line2D = get_node_or_null("DashWarning") as Line2D
	if not warning_line:
		return

	warning_line.visible = true
	warning_line.width = attack_dash_warning_width
	warning_line.default_color = attack_dash_warning_color
	_update_dash_warning_feedback()


func _update_dash_warning_feedback() -> void:
	var warning_line: Line2D = get_node_or_null("DashWarning") as Line2D
	if not warning_line:
		return

	var warning_length: float = attack_dash_speed * attack_dash_duration + attack_dash_hit_radius
	var progress: float = 1.0 - (_dash_windup_timer / maxf(attack_dash_windup_time, 0.001))
	var warning_color: Color = attack_dash_warning_color
	warning_color.a = lerpf(0.22, attack_dash_warning_color.a, progress)

	WARNING_VISUALS.configure_dash_warning(
		warning_line,
		global_position,
		_dash_direction,
		warning_length,
		attack_dash_warning_width,
		warning_color
	)


func _hide_dash_warning() -> void:
	var warning_line: Line2D = get_node_or_null("DashWarning") as Line2D
	if not warning_line:
		return

	WARNING_VISUALS.hide_dash_warning(warning_line)


func _spawn_damage_feedback(world_position: Vector2) -> void:
	_spawn_damage_feedback_amount(attack_damage, world_position)


func _spawn_damage_feedback_amount(amount: int, world_position: Vector2) -> void:
	if is_instance_valid(game) and game.has_method("spawn_damage_feedback"):
		game.call("spawn_damage_feedback", amount, world_position, Color(0.55, 1.0, 0.82))


func _start_attack_cooldown() -> void:
	_attack_timer = attack_interval
	_attack_flash_timer = attack_flash_time


func _update_trail(delta: float) -> void:
	# Aliado crawler nao escolhe alvo: ele controla espaco deixando zonas de dano pelo caminho.
	_trail_timer = maxf(_trail_timer - delta, 0.0)
	if _trail_timer > 0.0:
		return

	if is_instance_valid(game) and game.has_method("spawn_ally_trail"):
		game.call("spawn_ally_trail", global_position, trail_damage, trail_radius, trail_duration, trail_tick_interval, trail_color)
	_trail_timer = trail_spawn_interval


func _update_dash_trail(delta: float) -> void:
	if not dash_leaves_trail_during_attack:
		return

	_dash_trail_timer = maxf(_dash_trail_timer - delta, 0.0)
	if _dash_trail_timer > 0.0:
		return

	if is_instance_valid(game) and game.has_method("spawn_ally_trail"):
		game.call("spawn_ally_trail", global_position, trail_damage, trail_radius, trail_duration, trail_tick_interval, trail_color)
	_dash_trail_timer = dash_trail_spawn_interval


func _update_shield_push(delta: float) -> void:
	_shield_push_timer = maxf(_shield_push_timer - delta, 0.0)
	if _shield_push_timer > 0.0:
		return

	if _push_enemies_away_from_player():
		if shield_push_shows_barrier_feedback:
			_show_pulse_feedback()
		_shield_push_timer = shield_push_interval


func _push_enemies_away_from_player() -> bool:
	# O shield empurra sempre para fora do player, evitando jogar inimigos para dentro da area segura.
	var nearby_nodes: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var pushed_enemy: bool = false

	for nearby_node in nearby_nodes:
		var enemy: Enemy = nearby_node as Enemy
		if not is_instance_valid(enemy):
			continue

		var enemy_distance_to_player: float = enemy.global_position.distance_to(player.global_position)
		var enemy_distance_to_shield: float = enemy.global_position.distance_to(global_position)
		if enemy_distance_to_player <= orbit_radius or enemy_distance_to_shield > shield_push_radius:
			continue

		var push_direction: Vector2 = (enemy.global_position - player.global_position).normalized()
		enemy.global_position += push_direction * shield_push_distance
		pushed_enemy = true

	return pushed_enemy


func _damage_pursuit_chain(first_enemy: Enemy) -> void:
	if pursuit_chain_count <= 0:
		return

	var chain_damage: int = maxi(1, int(roundf(float(attack_damage) * pursuit_chain_damage_multiplier)))
	var excluded_enemies: Array[Enemy] = []
	excluded_enemies.append(first_enemy)
	_damage_enemies_in_radius(first_enemy.global_position, pursuit_chain_range, chain_damage, "melee", pursuit_chain_count, excluded_enemies)


func _damage_enemies_in_radius(
	center: Vector2,
	radius: float,
	damage_amount: int,
	attack_type: String,
	max_targets: int = -1,
	excluded_enemies: Array[Enemy] = []
) -> int:
	var enemies_hit: int = 0
	var nearby_nodes: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for nearby_node in nearby_nodes:
		var enemy: Enemy = nearby_node as Enemy
		if not is_instance_valid(enemy) or excluded_enemies.has(enemy):
			continue
		if center.distance_to(enemy.global_position) > radius:
			continue

		var actual_damage: int = enemy.take_damage(damage_amount, attack_type)
		if actual_damage > 0:
			_spawn_damage_feedback_amount(actual_damage, enemy.global_position)
		enemies_hit += 1
		if max_targets > 0 and enemies_hit >= max_targets:
			break

	return enemies_hit


func _is_inside_command_radius() -> bool:
	# Aliados especiais so atacam se ainda estiverem sob controle da formacao do jogador.
	return global_position.distance_to(player.global_position) <= attack_command_radius
