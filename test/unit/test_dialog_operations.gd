extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_operations() -> void:
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

func test_operation_with_text() -> void:
	var dialog_list = {
		'A': [
			{
				"op": ["+", "foo", 7],
				"text": "some text"
			}
		]
	}
	dialog.setup_dialog(dialog_list, { 'foo': 10 })
	dialog.start('A')
	var next = dialog.next()
	print(next)
	assert_eq(next.text, "some text")
	assert_eq(dialog.variables['foo'], 17)

func test_operation_with_then() -> void:
	var dialog_list = {
		'A': [
			{
				"op": ["+", "foo", 3],
				"then": "B",
			}
		],
		'B': [
			{
				"op": ["+", "foo", 2],
				"text": "in dialog B"
			}
		]
	}
	dialog.setup_dialog(dialog_list, { 'foo': 10 })
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "in dialog B")
