tool
class_name DialinkPlugin
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("DialogSystem", "Node", preload("DialogSystem.gd"), preload("assets/dialog_system.png")) 

func _exit_tree() -> void:
	remove_custom_type("DialogSystem")
