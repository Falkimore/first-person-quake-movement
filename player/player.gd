class_name Player
extends CharacterBody3D


signal landed(last_velocity: Vector3)

@export var MAX_SPEED := 4.0
@export var GROUND_ACCEL := 24.0
@export var GROUND_FRICTION := 5.0
@export var AIR_ACCEL := 12.0
@export var JUMP_FORCE := 5.0
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
		velocity.y = JUMP_FORCE
	
	var input_dir := get_input_dir()
	var move_dir := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	move_dir = move_dir.normalized()
	
	var y_speed := velocity.y
	velocity.y = 0.0
	
	if is_on_floor():
		_ground_movement(delta, move_dir)
	else:
		_air_movement(delta, move_dir)
	
	velocity.y = y_speed
	
	var last_velocity := velocity
	var last_on_floor := is_on_floor()
	move_and_slide()
	
	# going from the air to the ground means we landed
	if (not last_on_floor) and is_on_floor():
		landed.emit(last_velocity)


# thanks https://adrianb.io/2015/02/14/bunnyhop.html
func _accelerate(delta: float, accel_dir: Vector3, accel_force: float) -> void:
	var proj_vel := velocity.dot(accel_dir)
	var accel_vel := delta * accel_force
	
	if proj_vel + accel_vel > MAX_SPEED:
		accel_vel = MAX_SPEED - proj_vel
	
	velocity += accel_dir * accel_vel


func _ground_movement(delta: float, move_dir: Vector3) -> void:
	var speed := velocity.length()
	
	if speed != 0.0:
		var drop := speed * GROUND_FRICTION * delta
		velocity *= maxf(speed - drop, 0.0) / speed
	
	_accelerate(delta, move_dir, GROUND_ACCEL)


func _air_movement(delta: float, move_dir: Vector3) -> void:
	_accelerate(delta, move_dir, AIR_ACCEL)
