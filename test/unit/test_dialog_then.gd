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

func test_then_with_multiple_sub_tree() -> void:
	var dialog_list = {
		'A': [
			{
				"text": "abc",
				"then": [
					{ "text": "sub-text 1" },
					{
						"text": "sub-text 2",
						"then": [
							{ "text": "sub-sub-text 1" },
							{ "text": "sub-sub-text 2" },
							{ "text": "the end" },
						]
					},
					{ "text": "sub-text 2" }
				]
			},
			{ "text": "never visited" }
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var list_of_text = []
	var has_next_node = true
	var security = 10
	while has_next_node and security > 0:
		security -= 1
		var next = dialog.next()
		has_next_node = next.has("text")
		if has_next_node:
			list_of_text.push_back(next.text)

	var expected_list_of_text = [
		"abc",
		"sub-text 1",
		"sub-text 2",
		"sub-sub-text 1",
		"sub-sub-text 2",
		"the end"
	]
	assert_eq(list_of_text, expected_list_of_text)
