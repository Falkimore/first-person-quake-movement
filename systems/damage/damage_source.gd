class_name DamageSource
extends RefCounted

var damage: float
var direction: Vector3 = Vector3.ZERO
var point: Vector3


func _init() -> void:
	pass


func set_damage(value: float) -> DamageSource:
	damage = value
	return self


func set_direction(value: Vector3) -> DamageSource:
	direction = value
	return self


func set_point(value: Vector3) -> DamageSource:
	point = value
	return self
