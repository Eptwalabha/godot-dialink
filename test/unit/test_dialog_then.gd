extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_then_redirect_to_corresponding_dialog() -> void:
	var dialog_list = {
		'A': [
			{ "then": "B" }
		],
		'B': [
			{ "text": "A -> B" }
		]
	}
	
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "A -> B")

func test_then_tries_to_redirect_to_sub_dialog_it_it_exists() -> void:
	var dialog_list = {
		'A': [{ "then": "C" }],
		'A.C': [{ "text": "sub-dialog A.C" }],
		'C': [{ "text": "dialog C" }]
	}
	
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "sub-dialog A.C")
