extends CharacterBody2D
class_name Ally

@export var orbit_radius: float = 58.0
@export var orbit_speed: float = 1.45
@export var move_speed: float = 260.0
@export var attack_damage: int = 6
@export var attack_range: float = 34.0
@export var attack_interval: float = 0.45
@export var ally_type: String = "slime"
@export var attack_mode: String = "melee"
@export var attack_command_radius: float = 9999.0
@export var pursuit_hit_radius: float = 24.0
@export var pursuit_duration: float = 0.9
@export var projectile_speed: float = 360.0
@export var projectile_color: Color = Color(0.58, 1.0, 0.95)
@export var attack_dash_speed: float = 360.0
@export var attack_dash_windup_time: float = 0.18
@export var attack_dash_duration: float = 0.24
@export var attack_dash_hit_radius: float = 24.0
@export var attack_flash_time: float = 0.12

@onready var visual: Node2D = $Visual as Node2D

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


func setup(target_player: Node2D, game_node: Node, index: int, count: int) -> void:
	player = target_player
	game = game_node
	slot_index = index
	slot_count = maxi(count, 1)


func update_orbit_slot(index: int, count: int) -> void:
	slot_index = index
	slot_count = maxi(count, 1)


func _ready() -> void:
	add_to_group("allies")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_orbit_time += delta * orbit_speed
	_attack_timer = maxf(_attack_timer - delta, 0.0)

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

	if _attack_timer == 0.0:
		_try_attack()

	_update_attack_feedback(delta)


func _process_dash_windup(delta: float) -> void:
	# O windup cria antecipacao visual: o aliado vai atacar, mas ainda nao causou dano.
	_dash_windup_timer = maxf(_dash_windup_timer - delta, 0.0)
	velocity = Vector2.ZERO
	move_and_slide()
	visual.scale = Vector2.ONE * 1.15

	if _dash_windup_timer == 0.0:
		_dash_timer = attack_dash_duration


func _process_dash(delta: float) -> void:
	# Durante a investida, o aliado atravessa o campo e acerta tudo perto do caminho.
	_dash_timer = maxf(_dash_timer - delta, 0.0)
	velocity = _dash_direction * attack_dash_speed
	move_and_slide()
	_damage_enemies_during_dash()
	visual.scale = Vector2.ONE * 1.32

	if _dash_timer == 0.0:
		_dash_hit_enemies.clear()
		_attack_timer = attack_interval


func _begin_pursuit_attack(enemy: Enemy) -> void:
	_pursuit_target = enemy
	_pursuit_timer = pursuit_duration


func _process_pursuit_attack(delta: float) -> void:
	# O bat aliado preserva a fantasia de criatura rapida: sai da orbita, morde e volta.
	if not is_instance_valid(_pursuit_target):
		_end_pursuit_attack(true)
		return

	_pursuit_timer = maxf(_pursuit_timer - delta, 0.0)
	if _pursuit_timer == 0.0:
		_end_pursuit_attack(true)
		return

	var to_enemy: Vector2 = _pursuit_target.global_position - global_position
	if to_enemy.length() <= pursuit_hit_radius:
		_pursuit_target.take_damage(attack_damage)
		_spawn_damage_feedback(_pursuit_target.global_position)
		_end_pursuit_attack(false)
		_update_attack_feedback(delta)
		return

	velocity = to_enemy.normalized() * move_speed
	move_and_slide()
	visual.scale = Vector2.ONE * 1.12


func _end_pursuit_attack(use_short_cooldown: bool) -> void:
	_pursuit_target = null
	if use_short_cooldown:
		_attack_timer = attack_interval * 0.45
	else:
		_start_attack_cooldown()


func _update_attack_feedback(delta: float) -> void:
	if _attack_flash_timer > 0.0:
		_attack_flash_timer = maxf(_attack_flash_timer - delta, 0.0)
		visual.scale = Vector2.ONE * 1.25
	else:
		visual.scale = Vector2.ONE


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
		"pursuit":
			return
		"shooter":
			_try_projectile_attack()
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

	enemy.take_damage(attack_damage)
	_spawn_damage_feedback(enemy.global_position)
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
			enemy.take_damage(attack_damage)
			_spawn_damage_feedback(enemy.global_position)
			hit_any_enemy = true

	if hit_any_enemy:
		_show_pulse_feedback()
		_start_attack_cooldown()


func _try_projectile_attack() -> void:
	# Atiradores aliados mantem a formacao e contribuem de longe.
	var enemy: Enemy = _find_nearest_enemy()
	if not enemy or global_position.distance_to(enemy.global_position) > attack_range:
		return

	if is_instance_valid(game) and game.has_method("spawn_ally_projectile"):
		game.call("spawn_ally_projectile", global_position, enemy.global_position, attack_damage, projectile_speed, projectile_color)
	_start_attack_cooldown()


func _show_pulse_feedback() -> void:
	var pulse_node: Node2D = get_node_or_null("Visual/Pulse") as Node2D
	if not pulse_node:
		return

	pulse_node.visible = true
	pulse_node.scale = Vector2.ONE * 1.35

	var tween: Tween = create_tween()
	tween.tween_property(pulse_node, "scale", Vector2.ONE * 0.2, attack_flash_time)
	tween.parallel().tween_property(pulse_node, "modulate:a", 0.0, attack_flash_time)
	tween.tween_callback(_hide_pulse_feedback.bind(pulse_node))


func _hide_pulse_feedback(pulse_node: Node2D) -> void:
	if not is_instance_valid(pulse_node):
		return

	pulse_node.visible = false
	pulse_node.modulate.a = 1.0
	pulse_node.scale = Vector2.ONE


func _begin_dash_attack(enemy: Enemy) -> void:
	# O javali aliado herda a personalidade de inimigo: mira, prepara e investe.
	_dash_direction = (enemy.global_position - global_position).normalized()
	if _dash_direction == Vector2.ZERO:
		_dash_direction = Vector2.RIGHT

	_dash_hit_enemies.clear()
	_dash_windup_timer = attack_dash_windup_time
	_attack_flash_timer = attack_flash_time


func _damage_enemies_during_dash() -> void:
	var nearby_nodes: Array[Node] = get_tree().get_nodes_in_group("enemies")

	for nearby_node in nearby_nodes:
		var enemy: Enemy = nearby_node as Enemy
		if not is_instance_valid(enemy) or _dash_hit_enemies.has(enemy):
			continue

		if global_position.distance_to(enemy.global_position) <= attack_dash_hit_radius:
			enemy.take_damage(attack_damage)
			_dash_hit_enemies.append(enemy)
			_spawn_damage_feedback(enemy.global_position)


func _spawn_damage_feedback(world_position: Vector2) -> void:
	if is_instance_valid(game) and game.has_method("spawn_damage_feedback"):
		game.call("spawn_damage_feedback", attack_damage, world_position, Color(0.55, 1.0, 0.82))


func _start_attack_cooldown() -> void:
	_attack_timer = attack_interval
	_attack_flash_timer = attack_flash_time


func _is_inside_command_radius() -> bool:
	# Aliados especiais so atacam se ainda estiverem sob controle da formacao do jogador.
	return global_position.distance_to(player.global_position) <= attack_command_radius
