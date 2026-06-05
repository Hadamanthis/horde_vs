extends Node2D

signal enemy_died(enemy_type: String, death_position: Vector2)
signal enemy_converted(enemy_type: String, conversion_position: Vector2)
signal xp_collected(amount: int)
signal level_up(new_level: int)
signal upgrade_selected(upgrade_id: String)
signal game_lost
signal game_won

const SLIME_SCENE: PackedScene = preload("res://scenes/entities/enemies/Slime.tscn")
const BAT_SCENE: PackedScene = preload("res://scenes/entities/enemies/Bat.tscn")
const BOAR_SCENE: PackedScene = preload("res://scenes/entities/enemies/Boar.tscn")
const TOTEM_SCENE: PackedScene = preload("res://scenes/entities/enemies/Totem.tscn")
const SPITTER_SCENE: PackedScene = preload("res://scenes/entities/enemies/Spitter.tscn")
const SLIME_ALLY_SCENE: PackedScene = preload("res://scenes/entities/allies/SlimeAlly.tscn")
const BAT_ALLY_SCENE: PackedScene = preload("res://scenes/entities/allies/BatAlly.tscn")
const BOAR_ALLY_SCENE: PackedScene = preload("res://scenes/entities/allies/BoarAlly.tscn")
const TOTEM_ALLY_SCENE: PackedScene = preload("res://scenes/entities/allies/TotemAlly.tscn")
const SPITTER_ALLY_SCENE: PackedScene = preload("res://scenes/entities/allies/SpitterAlly.tscn")
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/entities/Projectile.tscn")
const XP_ORB_SCENE: PackedScene = preload("res://scenes/entities/XPOrb.tscn")
const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/effects/FloatingText.tscn")

@export var conversion_chance: float = 0.2
@export var ally_limit: int = 5
@export var enabled_enemy_types: Array[String] = ["slime", "bat", "boar", "totem", "spitter"]
@export var max_enemies: int = 42
@export var spawn_interval: float = 1.15
@export var match_duration: float = 300.0
@export var max_enemies_at_end: int = 85
@export var spawn_interval_at_end: float = 0.42
@export var initial_enemy_count: int = 10
@export var bat_start_time: float = 25.0
@export var bat_spawn_weight: float = 0.25
@export var boar_start_time: float = 55.0
@export var boar_spawn_weight: float = 0.22
@export var totem_start_time: float = 105.0
@export var totem_spawn_weight: float = 0.12
@export var spitter_start_time: float = 80.0
@export var spitter_spawn_weight: float = 0.16
@export var spawn_safe_margin: float = 160.0
@export var contact_damage_tick_interval: float = 0.5
@export var show_debug_info: bool = false

# Referencias tipadas para os nos da cena principal.
@onready var world: Node2D = $World as Node2D
@onready var player: Player = $World/Player as Player
@onready var player_camera: Camera2D = $World/Player/Camera2D as Camera2D
@onready var entities: Node2D = $World/Entities as Node2D
@onready var projectiles: Node2D = $World/Projectiles as Node2D
@onready var xp_orbs: Node2D = $World/XPOrbs as Node2D
@onready var feedback: Node2D = $World/Feedback as Node2D
@onready var stats_label: Label = $HUD/Stats as Label
@onready var debug_label: Label = $HUD/DebugInfo as Label
@onready var hint_label: Label = $HUD/Hint as Label
@onready var start_panel: PanelContainer = $HUD/StartPanel as PanelContainer
@onready var start_button: Button = $HUD/StartPanel/Margin/VBox/StartButton as Button
@onready var game_over_panel: PanelContainer = $HUD/GameOverPanel as PanelContainer
@onready var game_over_title_label: Label = $HUD/GameOverPanel/Margin/VBox/Title as Label
@onready var game_over_stats_label: Label = $HUD/GameOverPanel/Margin/VBox/StatsText as Label
@onready var game_over_restart_button: Button = $HUD/GameOverPanel/Margin/VBox/RestartButton as Button
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
var _last_converted_enemy_type: String = "-"
var _pending_upgrade_count: int = 0
var _is_choosing_upgrade: bool = false
var _game_started: bool = false
var _game_is_over: bool = false
var _debug_toggle_was_down: bool = false
var _difficulty_progress: float = 0.0
var _current_spawn_interval: float = 1.15
var _current_max_enemies: int = 42


func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	start_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	start_panel.visible = true
	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_start_run)
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_panel.visible = false
	game_over_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_panel.visible = false
	game_over_restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_restart_button.pressed.connect(_restart_run)
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

	_current_spawn_interval = spawn_interval
	_current_max_enemies = max_enemies
	stats_label.visible = false
	player.set_control_enabled(false)
	get_tree().paused = true
	hint_label.text = "Clique em Comecar partida. F3 alterna debug."
	start_button.grab_focus()

	_update_hud()
	queue_redraw()


func _process(delta: float) -> void:
	_process_debug_toggle()

	if Input.is_key_pressed(KEY_R):
		_restart_run()

	if not _game_started:
		return

	if _is_choosing_upgrade:
		_process_upgrade_shortcuts()
		return

	# Depois da derrota, apenas o atalho de reinicio continua ativo.
	if _game_is_over:
		return

	elapsed_time += delta
	_update_match_progression()
	_spawn_timer -= delta
	_attack_timer -= delta
	_contact_damage_timer -= delta
	_level_notice_timer = maxf(_level_notice_timer - delta, 0.0)
	level_up_label.visible = _level_notice_timer > 0.0
	_update_contact_damage()

	if elapsed_time >= match_duration:
		_on_match_won()
		return

	if _spawn_timer <= 0.0 and enemies.size() < _current_max_enemies:
		_spawn_enemy()
		_spawn_timer = _current_spawn_interval

	if _attack_timer <= 0.0:
		_fire_player_projectile()
		_attack_timer = player.attack_interval

	_update_hud()
	queue_redraw()


func _start_run() -> void:
	if _game_started:
		return

	_game_started = true
	start_panel.visible = false
	stats_label.visible = true
	player.set_control_enabled(true)
	get_tree().paused = false
	hint_label.text = "WASD/setas movem. Ataque automatico. R reinicia. F3 debug."

	# A partida nasce com uma pequena horda inimiga para o loop aparecer imediatamente.
	for index in range(initial_enemy_count):
		_spawn_enemy(index * TAU / initial_enemy_count, _get_initial_enemy_scene())

	_update_hud()


func _process_debug_toggle() -> void:
	var debug_key_is_down: bool = Input.is_key_pressed(KEY_F3)
	if debug_key_is_down and not _debug_toggle_was_down:
		show_debug_info = not show_debug_info
		_update_hud()

	_debug_toggle_was_down = debug_key_is_down


func _update_match_progression() -> void:
	# Progressao linear inicial: quanto mais perto dos 5 minutos, maior a pressao.
	_difficulty_progress = clampf(elapsed_time / match_duration, 0.0, 1.0)
	_current_spawn_interval = lerpf(spawn_interval, spawn_interval_at_end, _difficulty_progress)
	_current_max_enemies = int(roundf(lerpf(float(max_enemies), float(max_enemies_at_end), _difficulty_progress)))


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
	enemy.projectile_requested.connect(_on_enemy_projectile_requested)
	entities.add_child(enemy)
	enemies.append(enemy)
	_last_spawned_enemy_type = enemy.enemy_type


func _choose_enemy_scene() -> PackedScene:
	# Cada tipo novo entra como uma peca capturavel com funcao propria no exercito.
	var spawn_table: Array[Dictionary] = []

	if _is_enemy_type_enabled("slime"):
		spawn_table.append({
			"scene": SLIME_SCENE,
			"weight": 1.0,
		})
	if _can_spawn_timed_enemy_type("bat", bat_start_time):
		spawn_table.append({
			"scene": BAT_SCENE,
			"weight": bat_spawn_weight,
		})
	if _can_spawn_timed_enemy_type("boar", boar_start_time):
		spawn_table.append({
			"scene": BOAR_SCENE,
			"weight": boar_spawn_weight,
		})
	if _can_spawn_timed_enemy_type("totem", totem_start_time):
		spawn_table.append({
			"scene": TOTEM_SCENE,
			"weight": totem_spawn_weight,
		})
	if _can_spawn_timed_enemy_type("spitter", spitter_start_time):
		spawn_table.append({
			"scene": SPITTER_SCENE,
			"weight": spitter_spawn_weight,
		})

	if spawn_table.is_empty():
		return _get_initial_enemy_scene()

	return _pick_weighted_enemy_scene(spawn_table)


func _get_initial_enemy_scene() -> PackedScene:
	# Se um unico tipo estiver ativo, ele nasce desde o inicio para facilitar testes isolados.
	if _is_only_enabled_enemy_type("bat"):
		return BAT_SCENE
	if _is_only_enabled_enemy_type("boar"):
		return BOAR_SCENE
	if _is_only_enabled_enemy_type("totem"):
		return TOTEM_SCENE
	if _is_only_enabled_enemy_type("spitter"):
		return SPITTER_SCENE
	if _is_enemy_type_enabled("slime"):
		return SLIME_SCENE
	if _is_enemy_type_enabled("bat"):
		return BAT_SCENE
	if _is_enemy_type_enabled("boar"):
		return BOAR_SCENE
	if _is_enemy_type_enabled("totem"):
		return TOTEM_SCENE
	if _is_enemy_type_enabled("spitter"):
		return SPITTER_SCENE

	return SLIME_SCENE


func _can_spawn_timed_enemy_type(enemy_type: String, start_time: float) -> bool:
	if not _is_enemy_type_enabled(enemy_type):
		return false

	return elapsed_time >= start_time or _is_only_enabled_enemy_type(enemy_type)


func _is_enemy_type_enabled(enemy_type: String) -> bool:
	return enabled_enemy_types.has(enemy_type)


func _is_only_enabled_enemy_type(enemy_type: String) -> bool:
	return enabled_enemy_types.size() == 1 and enabled_enemy_types[0] == enemy_type


func _pick_weighted_enemy_scene(spawn_table: Array[Dictionary]) -> PackedScene:
	var total_weight: float = 0.0
	for weight_entry in spawn_table:
		total_weight += float(weight_entry["weight"])

	var roll: float = randf() * total_weight
	var accumulated_weight: float = 0.0
	for scene_entry in spawn_table:
		accumulated_weight += float(scene_entry["weight"])
		if roll <= accumulated_weight:
			return scene_entry["scene"] as PackedScene

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


func spawn_ally_projectile(start_position: Vector2, target_position: Vector2, damage: int, projectile_speed: float, projectile_color: Color) -> void:
	_spawn_projectile(start_position, target_position, damage, "enemies", projectile_speed, projectile_color)


func _on_enemy_projectile_requested(
	start_position: Vector2,
	target_position: Vector2,
	damage: int,
	projectile_speed: float,
	projectile_color: Color
) -> void:
	if _game_is_over:
		return

	_spawn_projectile(start_position, target_position, damage, "player", projectile_speed, projectile_color)


func _spawn_projectile(
	start_position: Vector2,
	target_position: Vector2,
	damage: int,
	target_group: String,
	projectile_speed: float,
	projectile_color: Color
) -> void:
	var projectile: Projectile = PROJECTILE_SCENE.instantiate() as Projectile
	projectile.setup(start_position, target_position, damage, self, target_group, projectile_speed, projectile_color)
	projectiles.add_child(projectile)


func get_player_if_in_range(origin: Vector2, max_distance: float) -> Player:
	if not is_instance_valid(player):
		return null

	if origin.distance_to(player.global_position) <= max_distance:
		return player

	return null


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
		spawn_damage_feedback(_last_contact_damage, player.global_position, Color(1.0, 0.38, 0.3))
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
	var ally_scene: PackedScene = _get_ally_scene_for_enemy_type(enemy_type)
	var ally: Ally = ally_scene.instantiate() as Ally
	ally.global_position = spawn_position
	ally.attack_damage += ally_damage_bonus
	entities.add_child(ally)
	allies.append(ally)
	ally.setup(player, self, allies.size() - 1, allies.size())
	allies_converted += 1
	_last_converted_enemy_type = enemy_type
	enemy_converted.emit(enemy_type, spawn_position)
	_spawn_feedback_text("Convertido", spawn_position + Vector2(0.0, -28.0), Color(0.55, 1.0, 0.82))
	_refresh_ally_orbits()


func _get_ally_scene_for_enemy_type(enemy_type: String) -> PackedScene:
	# Cada inimigo convertido vira a cena aliada equivalente ao seu tipo.
	match enemy_type:
		"boar":
			return BOAR_ALLY_SCENE
		"totem":
			return TOTEM_ALLY_SCENE
		"spitter":
			return SPITTER_ALLY_SCENE
		"bat":
			return BAT_ALLY_SCENE
		_:
			return SLIME_ALLY_SCENE


func _on_xp_orb_collected(orb: Node2D, amount: int) -> void:
	if _game_is_over:
		return

	active_xp_orbs.erase(orb)
	current_xp += amount
	xp_collected.emit(amount)
	if is_instance_valid(orb):
		_spawn_feedback_text("+%d XP" % amount, orb.global_position, Color(0.82, 1.0, 0.28))

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
	if _game_is_over:
		return

	_game_is_over = true
	player.set_control_enabled(false)
	upgrade_panel.visible = false
	_is_choosing_upgrade = false
	_clear_hostile_nodes_after_defeat()
	get_tree().paused = true
	game_lost.emit()
	hint_label.text = "Aperte R para tentar de novo"
	_show_end_panel("Derrota")
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


func _on_match_won() -> void:
	if _game_is_over:
		return

	_game_is_over = true
	player.set_control_enabled(false)
	_clear_hostile_nodes_after_defeat()
	get_tree().paused = true
	game_won.emit()
	hint_label.text = "Partida vencida. Aperte R para jogar de novo."
	_show_end_panel("Vitoria")
	_update_hud()


func _show_end_panel(result_title: String) -> void:
	# O painel resume a partida usando os mesmos contadores mostrados no HUD/debug.
	game_over_title_label.text = result_title
	game_over_stats_label.text = "Tempo sobrevivido: %s\nNivel alcancado: %d\nInimigos derrotados: %d\nAliados convertidos: %d\nAliados no fim: %d/%d" % [
		_format_elapsed_time(),
		player_level,
		enemies_defeated,
		allies_converted,
		allies.size(),
		ally_limit,
	]
	game_over_panel.visible = true
	stats_label.visible = false
	debug_label.visible = false
	game_over_restart_button.grab_focus()


func _restart_run() -> void:
	# Sempre despausamos antes de recarregar; cenas novas devem iniciar sem herdar pausa.
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_player_health_changed(_current_health: int, _max_health: int) -> void:
	_update_hud()


func _update_hud() -> void:
	stats_label.text = "Vida: %d/%d\nNivel: %d\nXP: %d/%d\nTempo: %s\nMeta: %s\nPressao: %.0f%%\nVivos: %d/%d\nDerrotados: %d\nAliados: %d/%d\nConvertidos: %d" % [
		player.current_health,
		player.max_health,
		player_level,
		current_xp,
		xp_to_next_level,
		_format_elapsed_time(),
		_format_remaining_time(),
		_difficulty_progress * 100.0,
		enemies.size(),
		_current_max_enemies,
		enemies_defeated,
		allies.size(),
		ally_limit,
		allies_converted,
	]
	_update_debug_info()


func _update_debug_info() -> void:
	debug_label.visible = show_debug_info and not _game_is_over
	if not debug_label.visible:
		return

	var slime_count: int = _count_enemies_by_type("slime")
	var bat_count: int = _count_enemies_by_type("bat")
	var boar_count: int = _count_enemies_by_type("boar")
	var totem_count: int = _count_enemies_by_type("totem")
	var spitter_count: int = _count_enemies_by_type("spitter")
	var slime_ally_count: int = _count_allies_by_type("slime")
	var bat_ally_count: int = _count_allies_by_type("bat")
	var boar_ally_count: int = _count_allies_by_type("boar")
	var totem_ally_count: int = _count_allies_by_type("totem")
	var spitter_ally_count: int = _count_allies_by_type("spitter")
	debug_label.text = "DEBUG\nEstado: %s\nAtivos: %s\nPressao: %.0f%%\nSpawn atual: %.2fs\nLimite atual: %d\nInimigos vivos: %d/%d\nS:%d B:%d J:%d T:%d A:%d\nAliados S:%d B:%d J:%d T:%d A:%d\nUltimo spawn: %s\nUltima conversao: %s\nBats em: %.0fs\nJavali em: %.0fs\nAtirador em: %.0fs\nTotem em: %.0fs\nTocando player: %d\nUltimo dano contato: %d\nTick contato: %.2fs\nTimer contato: %.2f\nSpawn margem: %.0f\nChance conversao: %.0f%%\nDano orbe: %d\nAtk intervalo: %.2fs\nBonus dano aliados: +%d\nUltimo upgrade: %s" % [
		_get_debug_state_name(),
		_format_enabled_enemy_types(),
		_difficulty_progress * 100.0,
		_current_spawn_interval,
		_current_max_enemies,
		enemies.size(),
		_current_max_enemies,
		slime_count,
		bat_count,
		boar_count,
		totem_count,
		spitter_count,
		slime_ally_count,
		bat_ally_count,
		boar_ally_count,
		totem_ally_count,
		spitter_ally_count,
		_last_spawned_enemy_type,
		_last_converted_enemy_type,
		maxf(bat_start_time - elapsed_time, 0.0),
		maxf(boar_start_time - elapsed_time, 0.0),
		maxf(spitter_start_time - elapsed_time, 0.0),
		maxf(totem_start_time - elapsed_time, 0.0),
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


func spawn_damage_feedback(amount: int, world_position: Vector2, tint: Color = Color(1.0, 0.92, 0.58)) -> void:
	if amount <= 0 or _game_is_over:
		return

	_spawn_feedback_text("-%d" % amount, world_position + _get_feedback_offset(), tint)


func _spawn_feedback_text(message: String, world_position: Vector2, tint: Color) -> void:
	var floating_text: Node2D = FLOATING_TEXT_SCENE.instantiate() as Node2D
	floating_text.global_position = world_position
	floating_text.call("setup", message, tint)
	feedback.add_child(floating_text)


func _get_feedback_offset() -> Vector2:
	# Pequena variacao evita textos perfeitamente empilhados quando varios golpes acontecem.
	return Vector2(randf_range(-10.0, 10.0), randf_range(-18.0, -8.0))


func _format_elapsed_time() -> String:
	return _format_seconds(elapsed_time)


func _format_remaining_time() -> String:
	var remaining_time: float = maxf(match_duration - elapsed_time, 0.0)
	return _format_seconds(remaining_time)


func _format_seconds(total_seconds: float) -> String:
	var seconds: int = int(total_seconds) % 60
	var minutes: int = int(total_seconds / 60.0)
	return "%02d:%02d" % [minutes, seconds]


func _get_debug_state_name() -> String:
	if _game_is_over:
		return "derrota"
	if not _game_started:
		return "inicio"
	if _is_choosing_upgrade:
		return "upgrade"

	return "jogando"


func _count_enemies_by_type(enemy_type: String) -> int:
	var enemy_count: int = 0

	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.enemy_type == enemy_type:
			enemy_count += 1

	return enemy_count


func _count_allies_by_type(ally_type: String) -> int:
	var ally_count: int = 0

	for ally in allies:
		if is_instance_valid(ally) and ally.ally_type == ally_type:
			ally_count += 1

	return ally_count


func _format_enabled_enemy_types() -> String:
	if enabled_enemy_types.is_empty():
		return "nenhum"

	var formatted_types: String = ""
	for enemy_type in enabled_enemy_types:
		if formatted_types != "":
			formatted_types += ", "
		formatted_types += enemy_type

	return formatted_types


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
