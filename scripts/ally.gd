extends CharacterBody2D

@export var orbit_radius := 58.0
@export var orbit_speed := 1.45
@export var move_speed := 260.0
@export var attack_damage := 6
@export var attack_range := 34.0
@export var attack_interval := 0.45

var player: Node2D
var game: Node
var slot_index := 0
var slot_count := 1

var _attack_timer := 0.0
var _orbit_time := 0.0


func setup(target_player: Node2D, game_node: Node, index: int, count: int) -> void:
	player = target_player
	game = game_node
	slot_index = index
	slot_count = max(count, 1)


func update_orbit_slot(index: int, count: int) -> void:
	slot_index = index
	slot_count = max(count, 1)


func _ready() -> void:
	add_to_group("allies")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_orbit_time += delta * orbit_speed
	_attack_timer = max(_attack_timer - delta, 0.0)

	var ring := floor(float(slot_index) / 10.0)
	var members_in_ring := min(slot_count - int(ring) * 10, 10)
	var local_index := slot_index - int(ring) * 10
	var angle_step := TAU / max(float(members_in_ring), 1.0)
	var angle := local_index * angle_step + _orbit_time + ring * 0.55
	var desired_position := player.global_position + Vector2.RIGHT.rotated(angle) * (orbit_radius + ring * 28.0)

	velocity = (desired_position - global_position) * 6.0
	velocity = velocity.limit_length(move_speed)
	move_and_slide()

	var enemy := _find_nearest_enemy()
	if enemy and global_position.distance_to(enemy.global_position) <= attack_range and _attack_timer == 0.0:
		enemy.take_damage(attack_damage)
		_attack_timer = attack_interval


func _find_nearest_enemy() -> Node2D:
	if not is_instance_valid(game) or not game.has_method("get_nearest_enemy"):
		return null

	return game.get_nearest_enemy(global_position, attack_range)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(0.05, 0.13, 0.13))
	draw_circle(Vector2.ZERO, 7.5, Color(0.35, 0.98, 0.66))
	draw_circle(Vector2(0.0, -6.0), 2.0, Color(0.82, 1.0, 0.9))
