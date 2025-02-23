extends Control


func start_game() -> void:
	SceneLoader.change_scene("res://scenes/test.tscn")

func exit_game() -> void:
	get_tree().quit()
