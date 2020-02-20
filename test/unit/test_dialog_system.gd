extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog

func setup():
	dialog = DialogSystem.new()

func test_error():
	dialog.start('non_existing_dialog')
	assert_eq('', dialog.current_dialog)
	assert_eq([], dialog.dialog_list())

func test_dialog_list():
	var dialog_list = {
		"dialog-one": [],
		"dialog-two": [],
		"dialog-three": [],
	}
	assert_true(dialog.setup_dialog(dialog_list))
	
	var expected_list1 = ['dialog-one', 'dialog-two', 'dialog-three']
	assert_eq(expected_list1, dialog.dialog_list())
	
	for dialog_key in dialog_list:
		dialog.start(dialog_key)
		assert_eq(dialog_key, dialog.current_dialog)

func test_dialog_next_with_text_only():
	var dialog_list = {
		"dialog-a": [
			{ "text": ["text 1"] },
			{ "text": ["text 2"] },
			{ "text": ["text 3", " text 3.2"] },
			{ "text": [" doctor : text 4", " text 4.2 "]},
			{ "text": [
				"text 5",
				{
					"if": ["visited", "dialog-b"],
					"text": ["text 6"],
				},
				" text 7",
				]
			},
			{ "text": ["x = $x"] },
			{ "text": ["x = $x"] },
		],
	}
	
	assert_true(dialog.setup_dialog(dialog_list))
	dialog.start('dialog-a')
	
	assert_eq("text 1", dialog.next().text)
	assert_eq("text 2", dialog.next().text)
	assert_eq("text 3 text 3.2", dialog.next().text)
	var node = dialog.next()
	assert_eq(" text 4 text 4.2 ", node.text)
	assert_eq("doctor", node.who)
	
	assert_eq("text 5 text 7", dialog.next().text)
	assert_eq("x = $x", dialog.next().text)
	dialog.variables['x'] = "abc"
	assert_eq("x = abc", dialog.next().text)
	
#	TODO: the code segfault on the following line
#	assert_eq({}, dialog.next())
