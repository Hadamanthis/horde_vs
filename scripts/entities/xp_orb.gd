extends Node2D
class_name XPOrb

signal collected(orb: Node2D, amount: int)

@export var amount: int = 1
@export var collect_radius: float = 22.0
@export var magnet_radius: float = 96.0
@export var magnet_speed: float = 220.0

var player: Node2D
var _pulse_time: float = 0.0


func setup(target_player: Node2D, xp_amount: int) -> void:
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
	# Cristal alto contraste: brilho ciano + nucleo amarelo para aparecer no chao escuro.
	var pulse: float = 1.0 + sin(_pulse_time * 8.0) * 0.12
	var radius: float = 8.0 * pulse
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

	draw_circle(Vector2.ZERO, radius + 5.0, Color(0.02, 0.07, 0.08, 0.82))
	draw_circle(Vector2.ZERO, radius + 2.0, Color(0.14, 0.95, 1.0, 0.38))
	draw_polygon(points, fill_colors)
	draw_polyline(outline, Color(0.03, 0.08, 0.04), 2.0)
