extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_starting_a_non_existing_dialog() -> void:
	dialog.start('non_existing_dialog')
	assert_eq(dialog.current_path, [])
	assert_eq(dialog.dialog_list(), [])

func test_dialog_list() -> void:
	var dialog_list = {
		"dialog-one": [],
		"dialog-two": [],
		"dialog-three": [],
	}
	assert_true(dialog.setup_dialog(dialog_list))

	var expected_list1 = ['dialog-one', 'dialog-two', 'dialog-three']
	assert_eq(dialog.dialog_list(), expected_list1)

	for dialog_key in dialog_list:
		dialog.start(dialog_key)
		assert_eq(dialog.current_path, [dialog_key, 0])
