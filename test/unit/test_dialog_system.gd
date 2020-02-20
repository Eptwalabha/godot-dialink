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
			{ "text": "text 1" },
			{ "text": "text 2" },
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
			{ "text": "x = $x" },
			{ "text": "x = $x" },
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
	dialog.set_var("x", "abc")

	assert_eq("x = abc", dialog.next().text)
	assert_eq({}.hash(), dialog.next().hash())

func test_dialog_with_choices():
	var dialog_list = {
		"choice-a": [
			{
				"text": "this is a choice",
				"choices": [
					{ "text": "choice a" },
					{
						"text": "choice b",
						"then": [
							{ "text": "sub-choice b" }
						]
					},
					{
						"text": "choice c",
						"then": "dialog-b"
					},
				]
			}
		],
		"dialog-b": [
			{ "text" : "the end" }
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('choice-a')

	var node = dialog.next()
	assert_eq("this is a choice", node.text)
	assert_eq(3, node.choices.size())
	assert_eq("choice a", node.choices[0].text)
	assert_eq(0, node.choices[0].id)
	assert_eq("choice b", node.choices[1].text)
	assert_eq(1, node.choices[1].id)
	assert_eq("choice c", node.choices[2].text)
	assert_eq(2, node.choices[2].id)

	assert_eq(node.hash(), dialog.next().hash())

	var next = dialog.choice_next(0)
	assert_eq({}.hash(), next.hash())

	dialog.start('choice-a')
	dialog.next()
	next = dialog.choice_next(1)
	assert_eq("sub-choice b", next.text)

	dialog.start('choice-a')
	dialog.next()
	next = dialog.choice_next(2)
	assert_eq("the end", next.text)

func test_dialog_with_conditional_choices():
	var dialog_list = {
		"A": [
			{
				"text": "alice: choice list A # super # test",
				"choices": [
					{
						"if": ["not_visited", "B"],
						"text": "visit B",
						"then": "B"
					},
					{
						"if": ["visited", "B"],
						"text": "visit B again",
						"then": "B"
					},
					{
						"if": ["test", "foo", "eq", 2],
						"text": "foo is 2"
					},
					{
						"text": "quit"
					}
				]
			}
		],
		"B": [
			{
				"text": "in dialog B",
				"then": "A",
			},
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var node = dialog.next()
	assert_eq(" choice list A ", node.text)
	assert_eq(["super", "test"], node.tags)
	assert_eq(2, node.choices.size())
	assert_eq("visit B", node.choices[0].text)
	assert_eq(0, node.choices[0].id)
	assert_eq("quit", node.choices[1].text)
	assert_eq(3, node.choices[1].id)

	node = dialog.choice_next(0)
	assert_eq("in dialog B", node.text)

	node = dialog.next()
	assert_eq(" choice list A ", node.text)
	assert_eq(2, node.choices.size())
	assert_eq("visit B again", node.choices[0].text)
	assert_eq(1, node.choices[0].id)
	assert_eq("quit", node.choices[1].text)
	assert_eq(3, node.choices[1].id)

	dialog.set_var("foo", 2)
	node = dialog.next()
	assert_eq(" choice list A ", node.text)
	assert_eq(3, node.choices.size())
	assert_eq("visit B again", node.choices[0].text)
	assert_eq(1, node.choices[0].id)
	assert_eq("foo is 2", node.choices[1].text)
	assert_eq(2, node.choices[1].id)
	assert_eq("quit", node.choices[2].text)
	assert_eq(3, node.choices[2].id)

	node = dialog.choice_next(3)
	assert_eq({}.hash(), node.hash())

func test_conditional():
	dialog.set_var("foo", 3)
	assert_false(dialog._if(["test", "foo", "eq", 5]))
	assert_true(dialog._if(["test", "foo", "eq", 3]))
	assert_false(dialog._if(["test", "foo", "eq", 1]))

	assert_true(dialog._if(["test", "foo", "ne", 5]))
	assert_false(dialog._if(["test", "foo", "ne", 3]))
	assert_true(dialog._if(["test", "foo", "ne", 1]))

	assert_true(dialog._if(["test", "foo", "lt", 5]))
	assert_false(dialog._if(["test", "foo", "lt", 3]))
	assert_false(dialog._if(["test", "foo", "lt", 1]))

	assert_true(dialog._if(["test", "foo", "le", 5]))
	assert_true(dialog._if(["test", "foo", "le", 3]))
	assert_false(dialog._if(["test", "foo", "le", 1]))

	assert_false(dialog._if(["test", "foo", "gt", 5]))
	assert_false(dialog._if(["test", "foo", "gt", 3]))
	assert_true(dialog._if(["test", "foo", "gt", 1]))

	assert_false(dialog._if(["test", "foo", "ge", 5]))
	assert_true(dialog._if(["test", "foo", "ge", 3]))
	assert_true(dialog._if(["test", "foo", "ge", 1]))

	assert_false(dialog._if(["test", "bar", "eq", "abc"]))
	dialog.set_var("bar", "abc")
	assert_true(dialog._if(["test", "bar", "eq", "abc"]))
	dialog.set_var("bar", "cba")
	assert_false(dialog._if(["test", "bar", "eq", "abc"]))
	assert_true(dialog._if(["test", "bar", "ne", "abc"]))
