extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog

func setup():
	dialog = DialogSystem.new()

func test_operations():
	var dialog_list = {
		"A": [
			{ "op": ["+", "foo", 2] },
			{ "op": ["-", "foo", 3] },
			{ "op": ["*", "foo", -6] },
			{ "text": "end part 1" },
			{ "op": ["/", "foo", 3] },
		],
		"B": [
			{ "op": ["+", "foo", -12] },
			{ "op": ["+", "bar", 10.0] },
			{ "text": "end part 2" },
			{ "op": ["=", "foo", 3.142] },
			{ "op": ["=", "bar", 0.111] },
			{ "op": ["=", "foo", "text"]}
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.set_var("foo", 0)
	dialog.start('A')
	assert_eq(dialog.variables['foo'], 0)
	var next = dialog.next()
	assert_eq(dialog.variables['foo'], 6)
	assert_eq(next.text, "end part 1")
	dialog.next()

	assert_eq(dialog.variables['foo'], 2)

	assert_false(dialog.variables.has('bar'))
	dialog.start('B')
	next = dialog.next()
	assert_eq(next.text, "end part 2")
	assert_true(dialog.variables.has('bar'))
	assert_eq(dialog.variables['foo'], -10)
	assert_eq(dialog.variables['bar'], 10.0)
	dialog.next()
	assert_eq(dialog.variables['foo'], "text")
	assert_eq(dialog.variables['bar'], 0.111)
