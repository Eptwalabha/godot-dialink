extends Node

onready var select := $UI/Menu/DialogSelection as OptionButton
onready var choices_container := $UI/Dialog/Content/Choices as VBoxContainer
onready var dialog_text := $UI/Dialog/Content/DialogText as RichTextLabel
onready var dialog_title := $UI/Dialog/Title as Label
onready var dialog_next := $UI/Dialog/Next as Button
onready var events := $UI/Events as RichTextLabel
onready var particle := $Particles2D as Particles2D
onready var dialog_box := $UI/Dialog as Control
onready var dialog_system := $DialogSystem as DialogSystem

var dialogs := []

func _ready() -> void:
	select.clear()
	for dialog in dialog_system.dialog_list():
		select.add_item(dialog)
	dialog_box.hide()

func update_dialog(data) -> void:
	var end_of_dialog = not data.has('text')
	dialog_box.visible = not end_of_dialog
	if not end_of_dialog:
		empty_choice_container()
		dialog_title.text = '' if not data.has('who') else data['who']
		dialog_text.set_bbcode(data.text.c_unescape())
		dialog_next.visible = not data.has('choices')
		if data.has('choices'):
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

func _on_StartDialog_pressed() -> void:
	var selected = select.get_selected_id()
	if selected > -1:
		var dialog = select.get_item_text(selected)
		dialog_system.start(dialog)
		var data = dialog_system.next()
		update_dialog(data)

func _on_NextDialog_pressed() -> void:
	var data = dialog_system.next()
	update_dialog(data)

func _on_DialogChoice_pressed(choice_id: int) -> void:
	empty_choice_container()
	var data = dialog_system.choice_next(choice_id)
	update_dialog(data)

func _on_DialogSystem_Event_emitted(dialog_name, event_name) -> void:
	var error = events.append_bbcode("new event '[b][color=blue]%s[/color][/b]' from dialog [color=blue]%s[/color]\n" % [event_name, dialog_name])
	if error:
		print("%s %s %s" % [error, dialog_name, event_name])
	if event_name == "particle":
		particle.emitting = true
