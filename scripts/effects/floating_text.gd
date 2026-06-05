extends Node2D
class_name FloatingText

@export var lifetime: float = 0.65
@export var rise_distance: float = 34.0
@export var start_scale: float = 0.9
@export var end_scale: float = 1.18

@onready var label: Label = $Label as Label

var _message: String = ""
var _tint: Color = Color.WHITE
var _age: float = 0.0
var _start_position: Vector2 = Vector2.ZERO


func setup(message: String, tint: Color) -> void:
	# O Game configura o texto no momento em que cria o efeito.
	_message = message
	_tint = tint
	if is_node_ready():
		_apply_label_state()


func _ready() -> void:
	_start_position = global_position
	_apply_label_state()


func _process(delta: float) -> void:
	_age += delta
	var progress: float = clampf(_age / lifetime, 0.0, 1.0)
	var alpha: float = 1.0 - progress

	global_position = _start_position + Vector2.UP * rise_distance * progress
	scale = Vector2.ONE * lerpf(start_scale, end_scale, progress)
	label.modulate = Color(_tint.r, _tint.g, _tint.b, alpha)

	if _age >= lifetime:
		queue_free()


func _apply_label_state() -> void:
	label.text = _message
	label.modulate = _tint
