extends Control

@export var keys: Array[Key]
@export var cameras: Array[Camera3D]


func _process(_delta: float) -> void:
	for i in range(keys.size()):
		if Input.is_key_label_pressed(keys[i]):
			for camera in cameras:
				camera.current = false
			cameras[i].current = true
