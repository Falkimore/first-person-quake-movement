class_name Player
extends CharacterBody3D


signal landed(last_velocity: Vector3)

@export var max_speed := 4.0
@export var ground_accel := 40.0
@export var ground_friction := 6.0
@export var air_accel := 4.0
@export var jump_force := 5.0
@export var cam_sensitivity := 0.01

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
		rotate_y(cam_sensitivity * -event.screen_relative.x)
		head.rotate_x(cam_sensitivity * -event.screen_relative.y)
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
		velocity.y = jump_force
	
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
	
	if proj_vel + accel_vel > max_speed:
		accel_vel = max_speed - proj_vel
	
	velocity += accel_dir * accel_vel


func _quake_accelerate(delta: float, wish_dir: Vector3, wish_speed: float, accel: float) -> void:
	var current_speed := velocity.dot(wish_dir)
	var add_speed := wish_speed - current_speed
	if add_speed <= 0.0:
		return
	
	var accel_speed := accel * delta
	if accel_speed > add_speed:
		accel_speed = add_speed
	
	velocity += accel_speed * wish_dir


func _ground_movement(delta: float, move_dir: Vector3) -> void:
	var speed := velocity.length()
	
	if speed != 0.0:
		var drop := speed * ground_friction * delta
		velocity *= maxf(speed - drop, 0.0) / speed
	
	_quake_accelerate(delta, move_dir, max_speed, ground_accel)


func _air_movement(delta: float, move_dir: Vector3) -> void:
	_quake_accelerate(delta, move_dir, max_speed, air_accel)
