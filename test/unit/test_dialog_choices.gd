extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_dialog_simple_choices() -> void:
	var dialog_list = {
		"A": [
			{
				"text": "this is a choice",
				"choices": [
					{
						"text": "choice a",
						"then": [
							{ "text": "a" }
						]
					},
					{
						"text": "choice b",
						"then": [
							{ "text": "b" }
						]
					}
				]
			}
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')

	var next = dialog.next()
	assert_eq(next.text, "this is a choice")
	assert_eq(next.choices.size(), 2)
	assert_eq(next.choices[0].text, "choice a")
	assert_eq(next.choices[0].id, 0)
	assert_eq(next.choices[1].text, "choice b")
	assert_eq(next.choices[1].id, 1)
	next = dialog.choice_next(0)
	assert_eq(next.text, "a")
	dialog.start('A')
	next = dialog.next()
	next = dialog.choice_next(1)
	assert_eq(next.text, "b")

func test_choices_with_then_redirection() -> void:
	var dialog_list = {
		"A": [
			{
				"text": "abc",
				"choices": [
					{
						"text": "dialog b",
						"then": "B"
					},
					{
						"text": "ask again",
						"then": "A"
					}
				]
			}
		],
		"B": [
			{ "text": "in dialog b" }
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')

	var next = dialog.next()
	assert_eq(next.text, "abc")
	assert_eq(next.choices.size(), 2)
	assert_eq(next.choices[0].text, "dialog b")
	assert_eq(next.choices[1].text, "ask again")
	next = dialog.choice_next(1)
	assert_eq(next.text, "abc")
	next = dialog.choice_next(0)
	assert_eq(next.text, "in dialog b")

func test_show_choices_depending_on_previously_visited_dialogs() -> void:
	var dialog_list = {
		"A": [
			{
				"text": "abc",
				"choices": [
					{
						"if": ["not_visited", "B"],
						"text": "B has not been visited yet",
						"then": "B"
					},
					{
						"if": ["visited", "B"],
						"text": "B has been visited"
					},
					{
						"text": "always show up"
					}
				]
			}
		],
		"B": [
			{ "then": "A" }
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.text, "abc")
	assert_eq(next.choices.size(), 2)
	assert_eq(next.choices[0].text, "B has not been visited yet")
	assert_eq(next.choices[0].id, 0)
	assert_eq(next.choices[1].text, "always show up")
	assert_eq(next.choices[1].id, 2)

	next = dialog.choice_next(0)
	assert_eq(next.text, "abc")
	assert_eq(next.choices.size(), 2)
	assert_eq(next.choices[0].text, "B has been visited")
	assert_eq(next.choices[0].id, 1)
	assert_eq(next.choices[1].text, "always show up")
	assert_eq(next.choices[1].id, 2)

	next = dialog.choice_next(1)
	assert_eq(next.hash(), {}.hash())

func test_show_choices_depending_on_previous_selection() -> void:
	var dialog_list = {
		"A": [
			{
				"text": "abc",
				"choices": [
					{
						"if": ["not_visited"],
						"text": "choice 1",
						"then": "A"
					},
					{
						"if": ["count_lower", 3],
						"text": "choice 2",
						"then": "A"
					},
					{
						"if": ["visited", ['A', 0, 0]],
						"text": "won't show until choice 1 selected"
					}
				]
			}
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var next = dialog.next()
	assert_eq(next.choices.size(), 2)
	assert_eq(next.choices[0].text, "choice 1")
	assert_eq(next.choices[0].id, 0)
	assert_eq(next.choices[1].text, "choice 2")
	assert_eq(next.choices[1].id, 1)
	next = dialog.choice_next(0)
	assert_eq(next.choices.size(), 2)
	assert_eq(next.choices[0].text, "choice 2")
	assert_eq(next.choices[0].id, 1)
	assert_eq(next.choices[1].text, "won't show until choice 1 selected")
	assert_eq(next.choices[1].id, 2)
	
	next = dialog.choice_next(1)
	next = dialog.choice_next(1)
	next = dialog.choice_next(1)

	assert_eq(next.choices.size(), 1)
	assert_eq(next.choices[0].text, "won't show until choice 1 selected")
	assert_eq(next.choices[0].id, 2)


func test_show_hide_choices() -> void:
	pass

func test_if_choice_has_already_been_picked_up() -> void:
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

func test_if_dialogs_has_been_visited() -> void:
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
