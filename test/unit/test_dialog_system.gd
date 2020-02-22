extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_error() -> void:
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

func test_dialog_next_with_text_only() -> void:
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

	assert_eq(dialog.next().text, "text 1")
	assert_eq(dialog.next().text, "text 2")
	assert_eq(dialog.next().text, "text 3 text 3.2")
	var node = dialog.next()
	assert_eq(node.text, " text 4 text 4.2 ")
	assert_eq(node.who, "doctor")

	assert_eq(dialog.next().text, "text 5 text 7")
	assert_eq(dialog.next().text, "x = $x")
	dialog.set_var("x", "abc")

	assert_eq(dialog.next().text, "x = abc")
	assert_eq(dialog.next().hash(), {}.hash())

func test_dialog_with_choices() -> void:
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
	assert_eq(node.text, "this is a choice")
	assert_eq(node.choices.size(), 3)
	assert_eq(node.choices[0].text, "choice a")
	assert_eq(node.choices[0].id, 0)
	assert_eq(node.choices[1].text, "choice b")
	assert_eq(node.choices[1].id, 1)
	assert_eq(node.choices[2].text, "choice c")
	assert_eq(node.choices[2].id, 2)

	assert_eq(dialog.next().hash(), node.hash())

	var next = dialog.choice_next(0)
	assert_eq(next.hash(), {}.hash())

	dialog.start('choice-a')
	dialog.next()
	next = dialog.choice_next(1)
	assert_eq(next.text, "sub-choice b")

	dialog.start('choice-a')
	dialog.next()
	next = dialog.choice_next(2)
	assert_eq(next.text, "the end")

func test_dialog_with_conditional_choices() -> void:
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
	assert_eq(node.text, " choice list A ")
	assert_eq(node.tags, ["super", "test"])
	assert_eq(node.choices.size(), 2)
	assert_eq(node.choices[0].text, "visit B")
	assert_eq(node.choices[0].id, 0)
	assert_eq(node.choices[1].text, "quit")
	assert_eq(node.choices[1].id, 3)

	node = dialog.choice_next(0)
	assert_eq(node.text, "in dialog B")

	node = dialog.next()
	assert_eq(node.text, " choice list A ")
	assert_eq(node.choices.size(), 2)
	assert_eq(node.choices[0].text, "visit B again")
	assert_eq(node.choices[0].id, 1)
	assert_eq(node.choices[1].text, "quit")
	assert_eq(node.choices[1].id, 3)

	dialog.set_var("foo", 2)
	node = dialog.next()
	assert_eq(node.text, " choice list A ")
	assert_eq(node.choices.size(), 3)
	assert_eq(node.choices[0].text, "visit B again")
	assert_eq(node.choices[0].id, 1)
	assert_eq(node.choices[1].text, "foo is 2")
	assert_eq(node.choices[1].id, 2)
	assert_eq(node.choices[2].text, "quit")
	assert_eq(node.choices[2].id, 3)

	node = dialog.choice_next(3)
	assert_eq(node.hash(), {}.hash())

func test_visit_dialogs() -> void:
	var dialog_list = {
		"A": [],
		"B": [],
		"C": [],
	}
	dialog.setup_dialog(dialog_list)
	dialog.start("A")
	assert_eq(dialog.visited['A'], 1)
	assert_false(dialog.visited.has('B'))
	assert_false(dialog.visited.has('C'))

	dialog.start("A")
	dialog.start("B")
	dialog.start("A")
	assert_eq(dialog.visited['A'], 3)
	assert_eq(dialog.visited['B'], 1)
	assert_false(dialog.visited.has('C'))

func test_visit_choices() -> void:
	var dialog_list = {
		"test": [
			{
				"text": "abc",
				"choices": [
					{ "text": "choice 1" },
					{ "text": "choice 2" },
					{ "text": "choice 3" },
					{
						"text": "choice 4",
						"then": [
							{
								"text": "abc",
								"choices": [
									{ "text": "choice 4-1" },
									{ "text": "choice 4-2" },
								]
							}
						]
					}
				]
			}
		],
	}
	dialog.setup_dialog(dialog_list)
	for choice_index in [0, 0, 1, 0, 2, 2, 0]:
		dialog.start("test")
		dialog.next()
		dialog.choice_next(choice_index)

	assert_eq(dialog.visited['test'], 7)
	assert_eq(dialog.visited[['test', 0, 0]], 4)
	assert_eq(dialog.visited[['test', 0, 1]], 1)
	assert_eq(dialog.visited[['test', 0, 2]], 2)

	for choice_index in [0, 1, 0, 0, 1, 1, 1, 1]:
		dialog.start("test")
		dialog.next()
		dialog.choice_next(3)
		dialog.choice_next(choice_index)

	assert_eq(dialog.visited['test'], 15)
	assert_eq(dialog.visited[['test', 0, 3, 0]], 8)
	assert_eq(dialog.visited[['test', 0, 3, 0, 0]], 3)
	assert_eq(dialog.visited[['test', 0, 3, 0, 1]], 5)
