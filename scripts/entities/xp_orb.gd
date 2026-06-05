extends Node2D
class_name XPOrb

signal collected(orb: Node2D, amount: int)

@export var amount: int = 1
@export var collect_radius: float = 22.0
@export var magnet_radius: float = 96.0
@export var magnet_speed: float = 220.0

@onready var visual: Node2D = $Visual as Node2D

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

	# O pulso fica no no Visual; o desenho em si aparece na cena como Polygon2D.
	var pulse: float = 1.0 + sin(_pulse_time * 8.0) * 0.12
	visual.scale = Vector2.ONE * pulse
