extends CanvasLayer

@onready var loading_screen: Control = $LoadingScreen
@onready var loading_progress_label: Label = $LoadingScreen/Progress

var loading_path := ""

func change_scene(change_path: String) -> void:
	var main := get_tree().current_scene
	if not ResourceLoader.exists(change_path, "PackedScene"):
		push_error("The path provided does not exist or does not lead to a PackedScene.")
	show_loading_screen()
	for child in main.get_children():
		child.queue_free()
	ResourceLoader.load_threaded_request(change_path, "PackedScene")
	loading_path = change_path

func _process(_delta: float) -> void:
	if not loading_path:
		hide_loading_screen()
		return
	var load_progress := [0.0]
	var load_status := ResourceLoader.load_threaded_get_status(loading_path, load_progress)
	match load_status:
		0:
			push_error("Tried to get status from a scene not being currently loaded! Perhaps you changed loading_path instead of using change_scene()?")
			loading_path = ""
			return
		1:
			load_status = ResourceLoader.load_threaded_get_status(loading_path, load_progress)
			loading_progress_label.text = String.num(load_progress.front() * 100, 0) + "%"
		2:
			push_error("Scene loading failed!")
			OS.crash("Scene loading failed!")
		3:
			var load_result: PackedScene = ResourceLoader.load_threaded_get(loading_path)
			var scene: Node = load_result.instantiate()
			get_tree().current_scene.add_child.call_deferred(scene, true)
			loading_path = ""


func show_loading_screen() -> void:
	loading_screen.visible = true

func hide_loading_screen() -> void:
	loading_screen.visible = false
	loading_progress_label.text = "0%"
