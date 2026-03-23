extends Control


@export var player: Player

@onready var debug_label: Label = $DebugLabel

func _process(_delta: float) -> void:
	debug_label.text = _get_debug_text()


func _get_debug_text() -> String:
	var vel := player.velocity
	
	return "Speed: (%.2f, %.2f, %.2f)\n" % [vel.x, vel.y, vel.z]
