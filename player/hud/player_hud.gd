extends Control


@export var player: Player

@onready var debug_label: Label = $DebugLabel

func _process(_delta: float) -> void:
	debug_label.text = _get_debug_text()


func _get_debug_text() -> String:
	var vel := player.velocity
	var horiz_speed := sqrt(vel.x * vel.x + vel.z * vel.z)
	
	var right := player.basis * Vector3.RIGHT
	var strafe_speed := vel.project(right).length()
	print(strafe_speed)
	
	return "Velocity: (%.2f, %.2f, %.2f)\n" % [vel.x, vel.y, vel.z] \
			+ "Horizontal speed: %.2f / %.2f\n" % [horiz_speed, player.max_speed] \
			+ "Strafing speed: %.2f" % strafe_speed
