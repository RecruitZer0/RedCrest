extends Control

@export var cameras: Dictionary[Key, Camera3D]


func _process(_delta: float) -> void:
	for key in cameras.keys():
		if Input.is_key_label_pressed(key):
			for camera in cameras.values():
				camera.current = false
			cameras[key].current = true
