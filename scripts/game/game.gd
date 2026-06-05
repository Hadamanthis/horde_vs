extends Node2D

signal enemy_died(enemy_type: String, death_position: Vector2)
signal enemy_converted(enemy_type: String, conversion_position: Vector2)
signal xp_collected(amount: int)
signal level_up(new_level: int)
signal upgrade_selected(upgrade_id: String)
signal game_lost

const SLIME_SCENE: PackedScene = preload("res://scenes/entities/enemies/Slime.tscn")
const BAT_SCENE: PackedScene = preload("res://scenes/entities/enemies/Bat.tscn")
const ALLY_SCENE: PackedScene = preload("res://scenes/entities/Ally.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/entities/Projectile.tscn")
const XP_ORB_SCENE: PackedScene = preload("res://scenes/entities/XPOrb.tscn")

@export var conversion_chance: float = 0.2
@export var ally_limit: int = 5
@export var max_enemies: int = 42
@export var spawn_interval: float = 1.15
@export var initial_enemy_count: int = 10
@export var bat_start_time: float = 25.0
@export var bat_spawn_chance: float = 0.25
@export var spawn_safe_margin: float = 160.0
@export var contact_damage_tick_interval: float = 0.5
@export var show_debug_info: bool = true

# Referencias tipadas para os nos da cena principal.
@onready var world: Node2D = $World as Node2D
@onready var player: Player = $World/Player as Player
@onready var player_camera: Camera2D = $World/Player/Camera2D as Camera2D
@onready var entities: Node2D = $World/Entities as Node2D
@onready var projectiles: Node2D = $World/Projectiles as Node2D
@onready var xp_orbs: Node2D = $World/XPOrbs as Node2D
@onready var stats_label: Label = $HUD/Stats as Label
@onready var debug_label: Label = $HUD/DebugInfo as Label
@onready var hint_label: Label = $HUD/Hint as Label
@onready var game_over_label: Label = $HUD/GameOver as Label
@onready var level_up_label: Label = $HUD/LevelUpNotice as Label
@onready var upgrade_panel: PanelContainer = $HUD/UpgradePanel as PanelContainer
@onready var upgrade_button_1: Button = $HUD/UpgradePanel/Margin/VBox/Upgrade1 as Button
@onready var upgrade_button_2: Button = $HUD/UpgradePanel/Margin/VBox/Upgrade2 as Button
@onready var upgrade_button_3: Button = $HUD/UpgradePanel/Margin/VBox/Upgrade3 as Button

var enemies: Array[Enemy] = []
var allies: Array[Ally] = []
var active_xp_orbs: Array[Node2D] = []
var upgrade_buttons: Array[Button] = []
var current_upgrade_choices: Array[Dictionary] = []
var upgrade_pool: Array[Dictionary] = [
	{
		"id": "orb_damage",
		"name": "Orbe mais forte",
		"description": "+3 dano no projetil automatico.",
	},
	{
		"id": "attack_speed",
		"name": "Ritual apressado",
		"description": "Ataque automatico 12% mais rapido.",
	},
	{
		"id": "move_speed",
		"name": "Passo sombrio",
		"description": "+10% velocidade de movimento.",
	},
	{
		"id": "conversion_chance",
		"name": "Chamado sombrio",
		"description": "+10% chance de converter inimigos.",
	},
	{
		"id": "ally_limit",
		"name": "Horda maior",
		"description": "+2 limite de aliados.",
	},
	{
		"id": "ally_damage",
		"name": "Garras da horda",
		"description": "Aliados causam +2 dano.",
	},
	{
		"id": "max_health",
		"name": "Sangue reserva",
		"description": "+20 vida maxima e cura 20.",
	},
	{
		"id": "pickup_range",
		"name": "Ima de almas",
		"description": "Cristais de XP sao atraidos de mais longe.",
	},
]

var enemies_defeated: int = 0
var allies_converted: int = 0
var player_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 5
var ally_damage_bonus: int = 0
var xp_magnet_bonus: float = 0.0
var elapsed_time: float = 0.0
var _spawn_timer: float = 0.0
var _attack_timer: float = 0.0
var _contact_damage_timer: float = 0.0
var _level_notice_timer: float = 0.0
var _touching_enemy_count: int = 0
var _last_contact_damage: int = 0
var _last_upgrade_id: String = "-"
var _last_spawned_enemy_type: String = "-"
var _pending_upgrade_count: int = 0
var _is_choosing_upgrade: bool = false
var _game_is_over: bool = false


func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_panel.visible = false
	upgrade_buttons.append(upgrade_button_1)
	upgrade_buttons.append(upgrade_button_2)
	upgrade_buttons.append(upgrade_button_3)

	# Sinais deixam o Player avisar o Game sem conhecer a estrutura da cena inteira.
	player.died.connect(_on_player_died)
	player.health_changed.connect(_on_player_health_changed)

	for index in range(upgrade_buttons.size()):
		var button: Button = upgrade_buttons[index]
		button.process_mode = Node.PROCESS_MODE_ALWAYS
		button.pressed.connect(_select_upgrade.bind(index))

	# Comecamos com slimes ao redor do jogador para testar o loop imediatamente.
	for index in range(initial_enemy_count):
		_spawn_enemy(index * TAU / initial_enemy_count, SLIME_SCENE)

	_update_hud()
	queue_redraw()


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		get_tree().paused = false
		get_tree().reload_current_scene()

	if _is_choosing_upgrade:
		_process_upgrade_shortcuts()
		return

	# Depois da derrota, apenas o atalho de reinicio continua ativo.
	if _game_is_over:
		return

	elapsed_time += delta
	_spawn_timer -= delta
	_attack_timer -= delta
	_contact_damage_timer -= delta
	_level_notice_timer = maxf(_level_notice_timer - delta, 0.0)
	level_up_label.visible = _level_notice_timer > 0.0
	_update_contact_damage()

	if _spawn_timer <= 0.0 and enemies.size() < max_enemies:
		_spawn_enemy()
		_spawn_timer = spawn_interval

	if _attack_timer <= 0.0:
		_fire_player_projectile()
		_attack_timer = player.attack_interval

	_update_hud()
	queue_redraw()


func get_nearest_enemy(origin: Vector2, max_distance: float) -> Enemy:
	var nearest_enemy: Enemy = null
	var nearest_distance_sq: float = max_distance * max_distance

	# Usamos distancia ao quadrado para evitar raiz quadrada a cada inimigo.
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance_sq: float = origin.distance_squared_to(enemy.global_position)
		if distance_sq <= nearest_distance_sq:
			nearest_distance_sq = distance_sq
			nearest_enemy = enemy

	return nearest_enemy


func _spawn_enemy(forced_angle: float = -1.0, enemy_scene: PackedScene = null) -> void:
	var scene_to_spawn: PackedScene = enemy_scene
	if not scene_to_spawn:
		scene_to_spawn = _choose_enemy_scene()

	var enemy: Enemy = scene_to_spawn.instantiate() as Enemy
	enemy.global_position = _get_spawn_position_outside_camera(forced_angle)
	enemy.setup(player)
	enemy.died.connect(_on_enemy_died)
	entities.add_child(enemy)
	enemies.append(enemy)
	_last_spawned_enemy_type = enemy.enemy_type


func _choose_enemy_scene() -> PackedScene:
	# A progressao ainda e simples: morcegos entram depois de alguns segundos.
	if elapsed_time >= bat_start_time and randf() <= bat_spawn_chance:
		return BAT_SCENE

	return SLIME_SCENE


func _get_spawn_position_outside_camera(forced_angle: float = -1.0) -> Vector2:
	# Inimigos nascem alem do retangulo visivel para o jogador nao ver o pop-in.
	var visible_rect: Rect2 = _get_camera_world_rect()
	var center: Vector2 = visible_rect.get_center()
	var half_size: Vector2 = visible_rect.size * 0.5
	var angle: float = forced_angle
	if angle < 0.0:
		angle = randf() * TAU

	var direction: Vector2 = Vector2.RIGHT.rotated(angle)
	var x_distance: float = 1000000.0
	var y_distance: float = 1000000.0
	if absf(direction.x) > 0.001:
		x_distance = half_size.x / absf(direction.x)
	if absf(direction.y) > 0.001:
		y_distance = half_size.y / absf(direction.y)

	var edge_distance: float = minf(x_distance, y_distance)
	var extra_distance: float = spawn_safe_margin + randf_range(0.0, 96.0)
	return center + direction * (edge_distance + extra_distance)


func _fire_player_projectile() -> void:
	# MVP sem mira manual: o alvo e sempre o inimigo mais proximo dentro do alcance.
	var target: Enemy = get_nearest_enemy(player.global_position, player.attack_range)
	if not target:
		return

	var projectile: Projectile = PROJECTILE_SCENE.instantiate() as Projectile
	projectile.setup(player.global_position, target.global_position, player.projectile_damage, self)
	projectiles.add_child(projectile)


func _update_contact_damage() -> void:
	# Dano de contato centralizado: um tick fixo se qualquer inimigo encostar.
	_touching_enemy_count = _count_touching_enemies()
	if _touching_enemy_count == 0:
		_last_contact_damage = 0
		_contact_damage_timer = 0.0
		return

	if _contact_damage_timer <= 0.0:
		_last_contact_damage = _get_touching_enemy_damage()
		player.take_damage(_last_contact_damage)
		_contact_damage_timer = contact_damage_tick_interval


func _count_touching_enemies() -> int:
	var touching_count: int = 0

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance: float = player.global_position.distance_to(enemy.global_position)
		if distance <= enemy.contact_range:
			touching_count += 1

	return touching_count


func _get_touching_enemy_damage() -> int:
	# Por enquanto nao somamos dano de varios inimigos; usamos o maior dano encostando.
	var contact_damage: int = 0

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		var distance: float = player.global_position.distance_to(enemy.global_position)
		if distance <= enemy.contact_range:
			contact_damage = maxi(contact_damage, enemy.contact_damage)

	return contact_damage


func _spawn_xp_orb(spawn_position: Vector2, amount: int) -> void:
	# XP tambem nasce no ponto da morte para reforcar a recompensa do combate.
	var orb: Node2D = XP_ORB_SCENE.instantiate() as Node2D
	orb.global_position = spawn_position
	orb.call("setup", player, amount)
	if xp_magnet_bonus > 0.0:
		var magnet_radius: float = float(orb.get("magnet_radius"))
		orb.set("magnet_radius", magnet_radius + xp_magnet_bonus)
	orb.connect("collected", Callable(self, "_on_xp_orb_collected"))
	xp_orbs.add_child(orb)
	active_xp_orbs.append(orb)


func _on_enemy_died(enemy: Enemy) -> void:
	if _game_is_over:
		return

	var death_position: Vector2 = enemy.global_position
	enemies.erase(enemy)
	enemies_defeated += 1
	enemy_died.emit(enemy.enemy_type, death_position)
	_spawn_xp_orb(death_position, enemy.xp_value)

	# Conversao e o coracao do jogo: parte dos inimigos derrotados vira aliado.
	if enemy.convertible and allies.size() < ally_limit and randf() <= conversion_chance:
		_convert_enemy(enemy.enemy_type, death_position)

	_update_hud()


func _convert_enemy(enemy_type: String, spawn_position: Vector2) -> void:
	# O aliado nasce no ponto da morte para vender visualmente a conversao.
	var ally: Ally = ALLY_SCENE.instantiate() as Ally
	ally.global_position = spawn_position
	ally.attack_damage += ally_damage_bonus
	entities.add_child(ally)
	allies.append(ally)
	ally.setup(player, self, allies.size() - 1, allies.size())
	allies_converted += 1
	enemy_converted.emit(enemy_type, spawn_position)
	_refresh_ally_orbits()


func _on_xp_orb_collected(orb: Node2D, amount: int) -> void:
	if _game_is_over:
		return

	active_xp_orbs.erase(orb)
	current_xp += amount
	xp_collected.emit(amount)

	# Pode subir mais de um nivel se no futuro um cristal valer bastante XP.
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		_gain_level()

	_update_hud()


func _gain_level() -> void:
	player_level += 1
	xp_to_next_level = int(ceil(float(xp_to_next_level) * 1.35 + 3.0))
	level_up_label.text = "Nivel %d" % player_level
	_level_notice_timer = 1.4
	_pending_upgrade_count += 1
	level_up.emit(player_level)

	if not _is_choosing_upgrade:
		_open_upgrade_choices()


func _open_upgrade_choices() -> void:
	# Durante a escolha, pausamos a simulacao para o jogador decidir sem ser punido.
	_is_choosing_upgrade = true
	get_tree().paused = true
	player.set_control_enabled(false)

	current_upgrade_choices = _roll_upgrade_choices(3)
	for index in range(upgrade_buttons.size()):
		var upgrade: Dictionary = current_upgrade_choices[index]
		var button: Button = upgrade_buttons[index]
		button.text = "%d. %s\n%s" % [
			index + 1,
			String(upgrade["name"]),
			String(upgrade["description"]),
		]

	upgrade_panel.visible = true
	hint_label.text = "Escolha um upgrade com clique ou teclas 1/2/3"


func _roll_upgrade_choices(amount: int) -> Array[Dictionary]:
	var available_upgrades: Array[Dictionary] = []
	var choices: Array[Dictionary] = []

	for upgrade in upgrade_pool:
		available_upgrades.append(upgrade)

	while choices.size() < amount and available_upgrades.size() > 0:
		var chosen_index: int = randi_range(0, available_upgrades.size() - 1)
		choices.append(available_upgrades[chosen_index])
		available_upgrades.remove_at(chosen_index)

	return choices


func _process_upgrade_shortcuts() -> void:
	if Input.is_key_pressed(KEY_1):
		_select_upgrade(0)
	elif Input.is_key_pressed(KEY_2):
		_select_upgrade(1)
	elif Input.is_key_pressed(KEY_3):
		_select_upgrade(2)


func _select_upgrade(choice_index: int) -> void:
	if not _is_choosing_upgrade or choice_index >= current_upgrade_choices.size():
		return

	var upgrade: Dictionary = current_upgrade_choices[choice_index]
	var upgrade_id: String = String(upgrade["id"])
	_apply_upgrade(upgrade_id)
	_last_upgrade_id = upgrade_id
	upgrade_selected.emit(upgrade_id)

	_pending_upgrade_count = maxi(_pending_upgrade_count - 1, 0)
	if _pending_upgrade_count > 0:
		_open_upgrade_choices()
		return

	_is_choosing_upgrade = false
	current_upgrade_choices.clear()
	upgrade_panel.visible = false
	hint_label.text = "WASD/setas movem. Ataque automatico. R reinicia."
	player.set_control_enabled(true)
	get_tree().paused = false
	_update_hud()


func _apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"orb_damage":
			player.projectile_damage += 3
		"attack_speed":
			player.attack_interval = maxf(player.attack_interval * 0.88, 0.35)
		"move_speed":
			player.speed *= 1.1
		"conversion_chance":
			conversion_chance = minf(conversion_chance + 0.1, 0.75)
		"ally_limit":
			ally_limit += 2
			_refresh_ally_orbits()
		"ally_damage":
			ally_damage_bonus += 2
			for ally in allies:
				if is_instance_valid(ally):
					ally.attack_damage += 2
		"max_health":
			player.increase_max_health(20)
		"pickup_range":
			xp_magnet_bonus += 40.0
			for orb in active_xp_orbs:
				if is_instance_valid(orb):
					var magnet_radius: float = float(orb.get("magnet_radius"))
					orb.set("magnet_radius", magnet_radius + 40.0)


func _refresh_ally_orbits() -> void:
	# Quando a quantidade muda, redistribuimos todos para manter a orbita organizada.
	for index in range(allies.size()):
		var ally: Ally = allies[index]
		if is_instance_valid(ally):
			ally.update_orbit_slot(index, allies.size())


func _on_player_died() -> void:
	_game_is_over = true
	get_tree().paused = false
	player.set_control_enabled(false)
	_clear_hostile_nodes_after_defeat()
	game_lost.emit()
	game_over_label.visible = true
	hint_label.text = "Aperte R para tentar de novo"
	_update_hud()


func _clear_hostile_nodes_after_defeat() -> void:
	# A derrota encerra a simulacao hostil; inimigos/projeteis somem e o jogador para.
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies.clear()

	var active_projectiles: Array[Node] = projectiles.get_children()
	for projectile in active_projectiles:
		projectile.queue_free()

	for orb in active_xp_orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	active_xp_orbs.clear()


func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	_update_hud()


func _update_hud() -> void:
	var seconds: int = int(elapsed_time) % 60
	var minutes: int = int(elapsed_time / 60.0)
	stats_label.text = "Vida: %d/%d\nNivel: %d\nXP: %d/%d\nTempo: %02d:%02d\nInimigos: %d\nAliados: %d/%d\nConvertidos: %d" % [
		player.current_health,
		player.max_health,
		player_level,
		current_xp,
		xp_to_next_level,
		minutes,
		seconds,
		enemies_defeated,
		allies.size(),
		ally_limit,
		allies_converted,
	]
	_update_debug_info()


func _update_debug_info() -> void:
	debug_label.visible = show_debug_info
	if not show_debug_info:
		return

	var slime_count: int = _count_enemies_by_type("slime")
	var bat_count: int = _count_enemies_by_type("bat")
	debug_label.text = "DEBUG\nEstado: %s\nInimigos vivos: %d/%d\nSlimes: %d | Bats: %d\nUltimo spawn: %s\nBats em: %.0fs\nTocando player: %d\nUltimo dano contato: %d\nTick contato: %.2fs\nTimer contato: %.2f\nSpawn margem: %.0f\nChance conversao: %.0f%%\nDano orbe: %d\nAtk intervalo: %.2fs\nBonus dano aliados: +%d\nUltimo upgrade: %s" % [
		"upgrade" if _is_choosing_upgrade else "jogando",
		enemies.size(),
		max_enemies,
		slime_count,
		bat_count,
		_last_spawned_enemy_type,
		maxf(bat_start_time - elapsed_time, 0.0),
		_touching_enemy_count,
		_last_contact_damage,
		contact_damage_tick_interval,
		maxf(_contact_damage_timer, 0.0),
		spawn_safe_margin,
		conversion_chance * 100.0,
		player.projectile_damage,
		player.attack_interval,
		ally_damage_bonus,
		_last_upgrade_id,
	]


func _count_enemies_by_type(enemy_type: String) -> int:
	var enemy_count: int = 0

	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.enemy_type == enemy_type:
			enemy_count += 1

	return enemy_count


func _draw() -> void:
	# O fundo acompanha a camera e considera o zoom; assim nao sobra borda cinza na tela.
	var visible_rect: Rect2 = _get_camera_world_rect()
	var padding: Vector2 = Vector2(256.0, 256.0)
	var top_left: Vector2 = visible_rect.position - padding * 0.5
	var visible_size: Vector2 = visible_rect.size + padding

	draw_rect(Rect2(top_left, visible_size), Color(0.055, 0.065, 0.07), true)

	var grid_color: Color = Color(0.13, 0.17, 0.15, 0.55)
	var grid_size: float = 64.0
	var start_x: float = floorf(top_left.x / grid_size) * grid_size
	var end_x: float = top_left.x + visible_size.x
	var start_y: float = floorf(top_left.y / grid_size) * grid_size
	var end_y: float = top_left.y + visible_size.y

	var x: float = start_x
	while x <= end_x:
		draw_line(Vector2(x, top_left.y), Vector2(x, end_y), grid_color, 1.0)
		x += grid_size

	var y: float = start_y
	while y <= end_y:
		draw_line(Vector2(top_left.x, y), Vector2(end_x, y), grid_color, 1.0)
		y += grid_size


func _get_camera_world_rect() -> Rect2:
	var viewport_rect: Rect2 = get_viewport_rect()
	var camera_center: Vector2 = Vector2.ZERO
	var visible_size: Vector2 = viewport_rect.size
	if is_instance_valid(player_camera):
		camera_center = player_camera.get_screen_center_position()
		visible_size = Vector2(
			viewport_rect.size.x / player_camera.zoom.x,
			viewport_rect.size.y / player_camera.zoom.y
		)
	elif is_instance_valid(player):
		camera_center = player.global_position

	return Rect2(camera_center - visible_size * 0.5, visible_size)
