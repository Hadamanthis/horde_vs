extends Node2D

signal enemy_died(enemy_type: String, death_position: Vector2)
signal enemy_converted(enemy_type: String, conversion_position: Vector2)
signal xp_collected(amount: int)
signal level_up(new_level: int)
signal game_lost

const ENEMY_SCENE: PackedScene = preload("res://scenes/Enemy.tscn")
const ALLY_SCENE: PackedScene = preload("res://scenes/Ally.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/Projectile.tscn")
const XP_ORB_SCENE: PackedScene = preload("res://scenes/XPOrb.tscn")

@export var conversion_chance: float = 0.2
@export var ally_limit: int = 5
@export var max_enemies: int = 42
@export var spawn_interval: float = 1.15
@export var initial_enemy_count: int = 10
@export var xp_per_slime: int = 1

# Referencias tipadas para os nos da cena principal.
@onready var player: Player = $Player as Player
@onready var entities: Node2D = $Entities as Node2D
@onready var projectiles: Node2D = $Projectiles as Node2D
@onready var xp_orbs: Node2D = $XPOrbs as Node2D
@onready var stats_label: Label = $HUD/Stats as Label
@onready var hint_label: Label = $HUD/Hint as Label
@onready var game_over_label: Label = $HUD/GameOver as Label
@onready var level_up_label: Label = $HUD/LevelUpNotice as Label

var enemies: Array[Enemy] = []
var allies: Array[Ally] = []
var active_xp_orbs: Array[XPOrb] = []

var enemies_defeated: int = 0
var allies_converted: int = 0
var player_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 5
var elapsed_time: float = 0.0
var _spawn_timer: float = 0.0
var _attack_timer: float = 0.0
var _level_notice_timer: float = 0.0
var _game_is_over: bool = false


func _ready() -> void:
	randomize()

	# Sinais deixam o Player avisar o Game sem conhecer a estrutura da cena inteira.
	player.died.connect(_on_player_died)
	player.health_changed.connect(_on_player_health_changed)

	# Comecamos com slimes ao redor do jogador para testar o loop imediatamente.
	for index in range(initial_enemy_count):
		_spawn_enemy(index * TAU / initial_enemy_count)

	_update_hud()
	queue_redraw()


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

	# Depois da derrota, apenas o atalho de reinicio continua ativo.
	if _game_is_over:
		return

	elapsed_time += delta
	_spawn_timer -= delta
	_attack_timer -= delta
	_level_notice_timer = max(_level_notice_timer - delta, 0.0)
	level_up_label.visible = _level_notice_timer > 0.0

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


func _spawn_enemy(forced_angle: float = -1.0) -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate() as Enemy
	var angle: float = forced_angle
	if angle < 0.0:
		angle = randf() * TAU

	# Spawn fora da area imediata do jogador para dar tempo de reagir.
	var distance: float = randf_range(360.0, 540.0)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
	enemy.setup(player)
	enemy.died.connect(_on_enemy_died)
	entities.add_child(enemy)
	enemies.append(enemy)


func _fire_player_projectile() -> void:
	# MVP sem mira manual: o alvo e sempre o inimigo mais proximo dentro do alcance.
	var target: Enemy = get_nearest_enemy(player.global_position, player.attack_range)
	if not target:
		return

	var projectile: Projectile = PROJECTILE_SCENE.instantiate() as Projectile
	projectile.setup(player.global_position, target.global_position, player.projectile_damage, self)
	projectiles.add_child(projectile)


func _spawn_xp_orb(spawn_position: Vector2, amount: int) -> void:
	# XP tambem nasce no ponto da morte para reforcar a recompensa do combate.
	var orb: XPOrb = XP_ORB_SCENE.instantiate() as XPOrb
	orb.global_position = spawn_position
	orb.setup(player, amount)
	orb.collected.connect(_on_xp_orb_collected)
	xp_orbs.add_child(orb)
	active_xp_orbs.append(orb)


func _on_enemy_died(enemy: Enemy) -> void:
	if _game_is_over:
		return

	var death_position: Vector2 = enemy.global_position
	enemies.erase(enemy)
	enemies_defeated += 1
	enemy_died.emit("slime", death_position)
	_spawn_xp_orb(death_position, xp_per_slime)

	# Conversao e o coracao do jogo: parte dos inimigos derrotados vira aliado.
	if enemy.convertible and allies.size() < ally_limit and randf() <= conversion_chance:
		_convert_enemy(death_position)

	_update_hud()


func _convert_enemy(spawn_position: Vector2) -> void:
	# O aliado nasce no ponto da morte para vender visualmente a conversao.
	var ally: Ally = ALLY_SCENE.instantiate() as Ally
	ally.global_position = spawn_position
	entities.add_child(ally)
	allies.append(ally)
	ally.setup(player, self, allies.size() - 1, allies.size())
	allies_converted += 1
	enemy_converted.emit("slime", spawn_position)
	_refresh_ally_orbits()


func _on_xp_orb_collected(orb: XPOrb, amount: int) -> void:
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
	level_up.emit(player_level)


func _refresh_ally_orbits() -> void:
	# Quando a quantidade muda, redistribuimos todos para manter a orbita organizada.
	for index in range(allies.size()):
		var ally: Ally = allies[index]
		if is_instance_valid(ally):
			ally.update_orbit_slot(index, allies.size())


func _on_player_died() -> void:
	_game_is_over = true
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


func _draw() -> void:
	# O fundo e desenhado por codigo para termos um mapa legivel antes da arte final.
	var viewport_rect: Rect2 = get_viewport_rect()
	var camera_center: Vector2 = Vector2.ZERO
	if is_instance_valid(player):
		camera_center = player.global_position

	var top_left: Vector2 = camera_center - viewport_rect.size * 0.5

	draw_rect(Rect2(top_left, viewport_rect.size), Color(0.08, 0.09, 0.1), true)

	var grid_color: Color = Color(0.16, 0.18, 0.17, 0.45)
	var grid_size: float = 64.0
	var start_x: float = floorf(top_left.x / grid_size) * grid_size
	var end_x: float = top_left.x + viewport_rect.size.x
	var start_y: float = floorf(top_left.y / grid_size) * grid_size
	var end_y: float = top_left.y + viewport_rect.size.y

	var x: float = start_x
	while x <= end_x:
		draw_line(Vector2(x, top_left.y), Vector2(x, end_y), grid_color, 1.0)
		x += grid_size

	var y: float = start_y
	while y <= end_y:
		draw_line(Vector2(top_left.x, y), Vector2(end_x, y), grid_color, 1.0)
		y += grid_size
