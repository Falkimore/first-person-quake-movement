class_name Player
extends CharacterBody3D


signal landed(last_velocity: Vector3)

@export var WALK_SPEED := 4.0
@export var WALK_ACCEL := 24.0
@export var JUMP_SPEED := 5.0
@export var CAM_SENSITIVITY := 0.01

@onready var head: Node3D = $Head
@onready var pause_menu: Control = $PauseMenu


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE:
			pause_menu.open()
	elif event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		rotate_y(CAM_SENSITIVITY * -event.screen_relative.x)
		head.rotate_x(CAM_SENSITIVITY * -event.screen_relative.y)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -80, 80)


func approach(a: Vector3, b: Vector3, x: float) -> Vector3:
	if a.distance_squared_to(b) > x*x:
		return a + (b-a).normalized()*x
	else:
		return b


func get_input_dir() -> Vector2:
	return Input.get_vector("move_left", "move_right", 
							"move_forward", "move_back")


func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		velocity.y = JUMP_SPEED
	
	var y_vel := velocity.y
	velocity.y = 0.0
	
	var input_dir := get_input_dir()
	var move_dir := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	var target_vel := move_dir * WALK_SPEED
	var accel: float
	if velocity.length_squared() > 0.0 and target_vel.length_squared() > 0.0:
		if target_vel.dot(velocity) > 0:
			accel = WALK_ACCEL
		else:
			accel = WALK_ACCEL * 2
	else:
		accel = WALK_ACCEL
	velocity = approach(velocity, target_vel, accel * delta)
	velocity.y = y_vel
	
	var last_velocity := velocity
	var last_on_floor := is_on_floor()
	move_and_slide()
	
	# going from the air to the ground means we landed
	if (not last_on_floor) and is_on_floor():
		landed.emit(last_velocity)
