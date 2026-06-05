extends Node2D
class_name XPOrb

signal collected(orb: XPOrb, amount: int)

@export var amount: int = 1
@export var collect_radius: float = 22.0
@export var magnet_radius: float = 96.0
@export var magnet_speed: float = 220.0

var player: Player
var _pulse_time: float = 0.0


func setup(target_player: Player, xp_amount: int) -> void:
	# O Game injeta o jogador para o cristal saber para onde ir quando esta perto.
	player = target_player
	amount = xp_amount


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	_pulse_time += delta

	var distance_to_player: float = global_position.distance_to(player.global_position)
	if distance_to_player <= collect_radius:
		collected.emit(self, amount)
		queue_free()
		return

	# Magnetismo leve: perto do jogador, o XP vem ate ele e a coleta fica mais gostosa.
	if distance_to_player <= magnet_radius:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		global_position += direction * magnet_speed * delta

	queue_redraw()


func _draw() -> void:
	# Cristal amarelo/verde para diferenciar recurso de inimigo e aliado.
	var pulse: float = 1.0 + sin(_pulse_time * 8.0) * 0.12
	var radius: float = 5.0 * pulse
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -radius),
		Vector2(radius * 0.8, 0.0),
		Vector2(0.0, radius),
		Vector2(-radius * 0.8, 0.0),
	])
	var outline: PackedVector2Array = points
	outline.append(points[0])

	var fill_colors: PackedColorArray = PackedColorArray([
		Color(0.75, 1.0, 0.35),
		Color(0.75, 1.0, 0.35),
		Color(0.75, 1.0, 0.35),
		Color(0.75, 1.0, 0.35),
	])

	draw_polygon(points, fill_colors)
	draw_polyline(outline, Color(0.16, 0.24, 0.08), 1.0)
