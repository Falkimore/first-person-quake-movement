class_name CameraBobber
extends Node

@export var player: Player
@export var camera: Camera3D

@export_group("Parameters")
@export var strafe_rotation: float = -0.08
@export var landing_impulse: float = 0.003
@export var damping_amount: float = 6.0


func _ready() -> void:
	if player:
		player.landed.connect(_landing_impact)


func _physics_process(delta: float) -> void:
	_strafing_effect(delta)
	_camera_damping(delta)


func _strafing_effect(delta: float) -> void:
	var input_dir := player.get_input_dir()
	var rotation_speed := input_dir.x * strafe_rotation
	camera.rotate_z(rotation_speed * delta)


func _landing_impact(last_velocity: Vector3) -> void:
	camera.rotate_x(last_velocity.y * landing_impulse)


func _camera_damping(delta: float) -> void:
	var weight := 1 - exp(-damping_amount * delta)
	camera.quaternion = camera.quaternion.slerp(Quaternion.IDENTITY, weight)
