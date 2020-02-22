extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_text_conditional() -> void:
	var dialog_list = {
		"A": [
			{
				"if": ["test", "foo", "eq", 1],
				"text": "foo = 1"
			},
			{
				"if": ["test", "foo", "ne", 1],
				"text": "foo != 1"
			}
		]
	}

	dialog.setup_dialog(dialog_list, { "foo": 1 })
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "foo = 1")

	dialog.set_var("foo", 2)
	dialog.start('A')
	next = dialog.next()
	assert_eq(next.text, "foo != 1")

func test_conditional_branching() -> void:
	var dialog_list = {
		"A": [
			{
				"if": ["test", "foo", "eq", 1],
				"then": "foo_is_one"
			},
			{
				"then": "foo_is_not_one"
			}
		],
		"A.foo_is_one": [
			{ "text": "foo is 1" }
		],
		"A.foo_is_not_one": [
			{ "text": "foo is not 1" }
		]
	}

	dialog.setup_dialog(dialog_list, { "foo": 1 })
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "foo is 1")

	dialog.set_var("foo", 2)
	dialog.start('A')
	next = dialog.next()
	assert_eq(next.text, "foo is not 1")

func test_conditional_text() -> void:
	var dialog_list = {
		"A": [
			{
				"text": [
					"A ",
					{
						"if": ["test", "foo", "gt", 5],
						"text": "B "
					},
					"C"
				]
			}
		]
	}
	
	dialog.setup_dialog(dialog_list, { "foo": 4 })
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "A C")

	dialog.set_var("foo", 6)
	dialog.start('A')
	next = dialog.next()
	assert_eq(next.text, "A B C")

func test_if_eq() -> void:
	dialog.set_var("foo", 3)
	assert_false(dialog._if(["test", "foo", "eq", 5]))
	assert_true(dialog._if(["test", "foo", "eq", 3]))
	assert_false(dialog._if(["test", "foo", "eq", 1]))

func test_if_ne() -> void:
	dialog.set_var("foo", 3)
	assert_true(dialog._if(["test", "foo", "ne", 5]))
	assert_false(dialog._if(["test", "foo", "ne", 3]))
	assert_true(dialog._if(["test", "foo", "ne", 1]))

func test_if_lt() -> void:
	dialog.set_var("foo", 3)
	assert_true(dialog._if(["test", "foo", "lt", 5]))
	assert_false(dialog._if(["test", "foo", "lt", 3]))
	assert_false(dialog._if(["test", "foo", "lt", 1]))

func test_if_le() -> void:
	dialog.set_var("foo", 3)
	assert_true(dialog._if(["test", "foo", "le", 5]))
	assert_true(dialog._if(["test", "foo", "le", 3]))
	assert_false(dialog._if(["test", "foo", "le", 1]))

func test_if_gt() -> void:
	dialog.set_var("foo", 3)
	assert_false(dialog._if(["test", "foo", "gt", 5]))
	assert_false(dialog._if(["test", "foo", "gt", 3]))
	assert_true(dialog._if(["test", "foo", "gt", 1]))

func test_if_ge() -> void:
	dialog.set_var("foo", 3)
	assert_false(dialog._if(["test", "foo", "ge", 5]))
	assert_true(dialog._if(["test", "foo", "ge", 3]))
	assert_true(dialog._if(["test", "foo", "ge", 1]))

func test_if_equality_with_text() -> void:
	dialog.set_var("foo", 3)
	assert_false(dialog._if(["test", "bar", "eq", "abc"]))
	dialog.set_var("bar", "abc")
	assert_true(dialog._if(["test", "bar", "eq", "abc"]))
	dialog.set_var("bar", "cba")
	assert_false(dialog._if(["test", "bar", "eq", "abc"]))
	assert_true(dialog._if(["test", "bar", "ne", "abc"]))
