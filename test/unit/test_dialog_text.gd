extends "res://addons/gut/test.gd"

var DialogSystem = preload("res://addons/dialink/DialogSystem.gd")
var dialog : DialogSystem

func setup() -> void:
	dialog = DialogSystem.new()

func test_text() -> void:
	var dialog_list = {
		"A": [
			{ "text": "simple text" },
			{ "text": ["other simple text"] },
			{ "text": ["simple ", "combined ", "text"] },
		]
	}
	
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var node = dialog.next()
	assert_eq(node.text, "simple text")
	node = dialog.next()
	assert_eq(node.text, "other simple text")
	node = dialog.next()
	assert_eq(node.text, "simple combined text")

func test_existing_variables_are_substituted() -> void:
	var dialog_list = {
		"A": [
			{ "text": "foo = $foo" },
			{ "text": "bar = $bar" },
			{ "text": "$foo $bar!" }
		]
	}
	var variables = {
		"foo": "hello",
		"bar": "world"
	}
	dialog.setup_dialog(dialog_list, variables)
	dialog.start('A')
	assert_eq(dialog.next().text, "foo = hello")
	assert_eq(dialog.next().text, "bar = world")
	assert_eq(dialog.next().text, "hello world!")

func test_undefined_variables_are_not_substituted() -> void:
	var dialog_list = {
		"A": [
			{ "text": "foo = $foo" },
			{ "text": "bar = $bar" },
			{ "text": "$foo $bar!" }
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	assert_eq(dialog.next().text, "foo = $foo")
	assert_eq(dialog.next().text, "bar = $bar")
	assert_eq(dialog.next().text, "$foo $bar!")

func test_conditional_text() -> void:
	var dialog_list = {
		"A": [
			{
				"text": [
					"hello ",
					{
						"if": ["visited", "B"],
						"text": "beautiful "
					},
					"world"
				]
			}
		],
		"B": [
			{
				"then": "A"
			}
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	assert_eq(dialog.next().text, "hello world")
	dialog.start('B')
	assert_eq(dialog.next().text, "hello beautiful world")
	dialog.start('A')
	assert_eq(dialog.next().text, "hello beautiful world")

func test_operations_are_done_before_displaying_text() -> void:
	var dialog_list = {
		"A": [
			{
				"op": ["=", "foo", "bar"],
				"text": "foo = $foo"
			}
		]
	}
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	assert_eq(dialog.next().text, "foo = bar")

func test_text_with_character_name() -> void:
	var dialog_list = {
		"A": [
			{ "text": "alice: Hello " },
			{ "text": "bob: Hello, how are you? " }
		]
	}

	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var node = dialog.next()
	assert_eq(node.text, "Hello")
	assert_eq(node.who, "alice")
	node = dialog.next()
	assert_eq(node.text, "Hello, how are you?")
	assert_eq(node.who, "bob")

func test_text_with_tags() -> void:
	var dialog_list = {
		"A": [
			{ "text": "a # hello    #    world   " },
			{ "text": "b # one two" },
			{ "text": "c ###"},
			{ "text": "d ##tag##"},
			{ "text": "e #$foo #$bar" }
		]
	}

	dialog.setup_dialog(dialog_list, { 'foo': "variable" })
	dialog.start('A')
	var node = dialog.next()
	assert_eq(node.text, "a")
	assert_eq(node.tags, ["hello", "world"])

	node = dialog.next()
	assert_eq(node.text, "b")
	assert_eq(node.tags, ["one two"])

	node = dialog.next()
	assert_eq(node.text, "c")
	assert_false(node.has('tags'))

	node = dialog.next()
	assert_eq(node.text, "d")
	assert_eq(node.tags, ["tag"])

	node = dialog.next()
	assert_eq(node.text, "e")
	assert_eq(node.tags, ["variable", "$bar"])

func test_text_with_events() -> void:
	var dialog_list = {
		"A": [
			{ "text": "a #!foo #bar" },
			{ "text": "b #foo #!bar" },
			{ "text": "c #!foo #!bar"}
		]
	}

	watch_signals(dialog)
	dialog.setup_dialog(dialog_list)
	dialog.start('A')
	var node = dialog.next()
	assert_eq(node.text, "a")
	assert_eq(node.tags, ["!foo", "bar"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 0), ["A", "foo"])

	node = dialog.next()
	assert_eq(node.text, "b")
	assert_eq(node.tags, ["foo", "!bar"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 1), ["A", "bar"])

	node = dialog.next()
	assert_eq(node.text, "c")
	assert_eq(node.tags, ["!foo", "!bar"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 2), ["A", "foo"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 3), ["A", "bar"])

	assert_eq(get_signal_emit_count(dialog, "event_emitted"), 4)

func test_text_with_character_name_tags_and_signal() -> void:
	var dialog_list = {
		"A": [
			{ "text": "$character-1: Hello $character-2 #$character-1 #!start conversation" },
			{ "text": "$character-2: Hello $character-1 #$character-2 #!end conversation" },
			{
				"text": [
					"$character-1: Good bye",
					{
						"if": ["test", "character-2", "eq", "Bob"],
						"text": " my friend"
					},
					{
						"if": ["test", "foo", "gt", 10],
						"text": "#big-foo"
					},
					{
						"if": ["test", "bar", "eq", "abc"],
						"text": "#bar-is-abc"
					},
					{
						"if": ["test", "character-2", "ne", "Alice"],
						"text": "#!this is $character-2"
					}
				]
			}
		]
	}
	var characters = {
		"character-1": "Alice",
		"character-2": "Bob",
	}
	watch_signals(dialog)
	dialog.setup_dialog(dialog_list, characters)
	dialog.start('A')
	var node = dialog.next()
	assert_eq(node.who, "Alice")
	assert_eq(node.text, "Hello Bob")
	assert_eq(node.tags, ["Alice", "!start conversation"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 0), ["A", "start conversation"])

	node = dialog.next()
	assert_eq(node.who, "Bob")
	assert_eq(node.text, "Hello Alice")
	assert_eq(node.tags, ["Bob", "!end conversation"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 1), ["A", "end conversation"])

	dialog.set_var("foo", 5)
	dialog.set_var("bar", "abc")
	node = dialog.next()
	assert_eq(node.who, "Alice")
	assert_eq(node.text, "Good bye my friend")
	assert_eq(node.tags, ["bar-is-abc", "!this is Bob"])
	assert_eq(get_signal_parameters(dialog, "event_emitted", 2), ["A", "this is Bob"])

	assert_eq(get_signal_emit_count(dialog, "event_emitted"), 3)

func test_complete_use_case() -> void:
	var dialog_list = {
		"A": [
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
	dialog.start('A')

	assert_eq(dialog.next().text, "text 1")
	assert_eq(dialog.next().text, "text 2")
	assert_eq(dialog.next().text, "text 3 text 3.2")
	var node = dialog.next()
	assert_eq(node.text, "text 4 text 4.2")
	assert_eq(node.who, "doctor")

	assert_eq(dialog.next().text, "text 5 text 7")
	assert_eq(dialog.next().text, "x = $x")
	dialog.set_var("x", "abc")

	assert_eq(dialog.next().text, "x = abc")
	assert_eq(dialog.next().hash(), {}.hash())
