tool
extends EditorPlugin

const TOUCH_INPUT_MANAGER_NAME = "TouchCameraEventInputManager"


func _enter_tree():
	add_autoload_singleton(TOUCH_INPUT_MANAGER_NAME, "res://addons/touch_camera/TouchInputManager.gd")


func _exit_tree():
	remove_autoload_singleton(TOUCH_INPUT_MANAGER_NAME)
