extends Control

var prev_mouse_mode: Input.MouseMode

func _ready() -> void:
	visible = false

func open() -> void:
	prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	get_tree().paused = true
	visible = true

func close() -> void:
	Input.mouse_mode = prev_mouse_mode
	
	get_tree().paused = false
	visible = false


func _on_resume_button_pressed() -> void:
	close()
