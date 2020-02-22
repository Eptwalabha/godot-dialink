extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_basic_math() -> void:
	var dialog_list = {
		'addition': [{ "op": ["+", "foo", 1] }],
		'substraction': [{ "op": ["-", "foo", 2] }],
		'multiplication': [{ "op": ["*", "foo", 3] }],
		'division': [{ "op": ["/", "foo", 4] }]
	}

	var variables = { 'foo': 5 }
	dialog.setup_dialog(dialog_list, variables)
	assert_eq(dialog.variables['foo'], 5)

	dialog.start('addition')
	dialog.next()
	assert_eq(dialog.variables['foo'], 6)

	dialog.start('substraction')
	dialog.next()
	assert_eq(dialog.variables['foo'], 4)

	dialog.start('multiplication')
	dialog.next()
	assert_eq(dialog.variables['foo'], 12)

	dialog.start('division')
	dialog.next()
	assert_eq(dialog.variables['foo'], 3)

func test_assignment() -> void:
	var dialog_list = {
		'existing-var': [{ 'op': ["=", "foo", 10] }],
		'new-var': [{ 'op': ["=", "bar", 4] }]
	}

	var variables = { 'foo': 5 }
	dialog.setup_dialog(dialog_list, variables)
	assert_eq(dialog.variables['foo'], 5)

	dialog.start('existing-var')
	dialog.next()
	assert_eq(dialog.variables['foo'], 10)

	dialog.start('new-var')
	assert_false(dialog.variables.has('bar'))
	dialog.next()
	assert_eq(dialog.variables['bar'], 4)

func test_assign_anything() -> void:
	var dialog_list = {
		'integer': [{ 'op': ["=", "foo", 10] }],
		'float': [{ 'op': ["=", "foo", -0.333] }],
		'text': [{ 'op': ["=", "foo", "bar"] }]
	}
	dialog.setup_dialog(dialog_list)
	assert_false(dialog.variables.has('foo'))
	dialog.start('integer')
	dialog.next()
	assert_eq(dialog.variables['foo'], 10)
	dialog.start('float')
	dialog.next()
	assert_eq(dialog.variables['foo'], -0.333)
	dialog.start('text')
	dialog.next()
	assert_eq(dialog.variables['foo'], 'bar')

func test_run_multiple_operations_until_text() -> void:
	var dialog_list = {
		'A': [
			{ "op": ["+", "foo", 1] },
			{ "op": ["+", "foo", 1] },
			{
				"op": ["+", "foo", 1],
				"then": "B"
			}
		],
		'B': [
			{ "op": ["+", "foo", 1] },
			{ "op": ["+", "foo", 1] },
			{
				"op": ["+", "foo", 1],
				"then": [
					{ "op": ["+", "foo", 1] },
					{
						"op": ["+", "foo", 1],
						"text": "end"
					}
				]
			}
		]
	}
	dialog.setup_dialog(dialog_list, { 'foo': 0 })
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "end")
	assert_eq(dialog.variables['foo'], 8)

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
	assert_eq(next.text, "some text")
	assert_eq(dialog.variables['foo'], 17)

func test_operation_with_then() -> void:
	var dialog_list = {
		'A': [
			{
				"op": ["+", "foo", 3],
				"then": "B",
			},
		],
		'B': [
			{
				"op": ["+", "foo", 2],
				"text": "in dialog B",
			},
		]
	}
	dialog.setup_dialog(dialog_list, { 'foo': 10 })
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "in dialog B")
