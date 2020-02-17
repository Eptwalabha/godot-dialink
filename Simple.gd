extends Node

onready var select := $UI/Menu/DialogSelection as OptionButton
onready var choices_container := $UI/Dialog/Content/Choices as VBoxContainer
onready var dialog_text := $UI/Dialog/Content/DialogText as RichTextLabel
onready var dialog_title := $UI/Dialog/Title as Label
onready var dialog_next := $UI/Dialog/Next as Button
onready var events := $UI/Events as RichTextLabel
onready var particle := $Particles2D as Particles2D
onready var dialog_box := $UI/Dialog as Control

var dialog_keys : Array = []
var dialogs := {}

func _ready() -> void:
	select.clear()
	var id = 0
	for dialog in dialogs:
		var d = dialogs[dialog]
		dialog_keys.push_back(d.key)
		select.add_item(d.label, id)
		id += 1
	dialog_box.hide()

func update_dialog(data) -> void:
	dialog_box.visible = data.type != 'end'
	if data.type != 'end':
		empty_choice_container()
		dialog_title.text = data.who
		dialog_text.set_bbcode(data.text.c_unescape())
		dialog_next.visible = data.type == 'dialog'
		if data.type == 'choice':
			for choice in data.choices:
				add_dialog_choice(choice.text, choice.id)

func empty_choice_container() -> void:
	for node in choices_container.get_children():
		choices_container.remove_child(node)
		node.queue_free()

func add_dialog_choice(label: String, choice_id: int) -> void:
	var choice_btn = Button.new()
	choice_btn.text = label
	choice_btn.flat = true
	choice_btn.align = Button.ALIGN_LEFT
	choice_btn.connect("pressed", self, "_on_DialogChoice_pressed", [choice_id], CONNECT_ONESHOT)
	choices_container.add_child(choice_btn)

func _on_Button_pressed() -> void:
	var selected = select.get_selected_id()
	if selected > -1:
		var dialog_key = dialog_keys[selected]

func _on_NextDialog_pressed() -> void:
	pass

func _on_DialogChoice_pressed(choice_id: int) -> void:
	empty_choice_container()
	pass

func _on_GameGraph_event_triggered(dialog_name, event_name) -> void:
	var error = events.append_bbcode("new event '[b][color=blue]%s[/color][/b]' from dialog [color=blue]%s[/color]\n" % [event_name, dialog_name])
	if error:
		print("%s %s %s" % [error, dialog_name, event_name])
	if event_name == "particle":
		particle.emitting = true
