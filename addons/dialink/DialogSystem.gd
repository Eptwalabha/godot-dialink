tool
class_name DialogSystem
extends Node

signal event_emitted(dialog, event_name)

export(Array, String, FILE) var dialog_files := [] setget _load_new_dialog_file

var file_valid = false
var variables := {}
var dialogs := {}
var visited := {}

var current_dialog : String = ''
var parent_dialog : String = ''
var current_path : Array = []
var last_node

func start(key: String) -> void:
	if not dialogs.has(key):
		return
	if not visited.has(key):
		visited[key] = 0
	visited[key] += 1
	current_dialog = key
	parent_dialog = key
	current_path = [0]

func next() -> Dictionary:
	var node = _current_node()
	if node.has('if'):
		if not _if(node['if']):
			_move_next_sibling()
			return next()
		else:
			_move_forward()
			return _do_next(node)
	_move_forward()
	return _do_next(node)

func _do_next(node) -> Dictionary:
	if _process_op(node):
		return next()
	elif _process_then(node):
		if not node.has('text'):
			return next()
		else:
			return _build_node(node)
	else:
		return _build_node(node)

func _process_op(node) -> bool:
	if node.has('op'):
		_op(node.get('op'))
		return true
	return false

func _process_then(node) -> bool:
	if node.has('then'):
		var then = node['then']
		if then is String:
			jump_to(then)
		if then is Array:
			current_path.push_back(0)
		return true
	return false

func choice_next(index: int) -> Dictionary:
	var node = _current_node()
	if index >= len(node['choices']):
		_clear_cursor()
		return {}
	current_path.push_back(index)
	var choice_path = current_path.duplicate()
	if not visited.has(choice_path):
		visited[choice_path] = 0
	visited[choice_path] += 1

	node = _current_node()
	if not node.has('then'):
		return {}
	var then = node['then']
	if then is String:
		jump_to(then)
	else:
		current_path.push_back(0)
	return next()

func _move_forward() -> void:
	var node = _current_node()
	if node.has('then'):
		var then = node['then']
		if then is String:
			jump_to(then)
		if then is Array:
			current_path.push_back(0)
	elif node.has('choices'):
		pass
	else:
		_move_next_sibling()

func _move_next_sibling() -> void:
		var first = current_path.pop_back()
		current_path.push_back(first + 1)

func _current_node() -> Dictionary:
	if current_dialog == '' or !dialogs.has(current_dialog) or !len(current_path):
		return {}
	var current = dialogs[current_dialog]
	for index in current_path:
		var element = []
		if current is Array:
			element = current
		elif current.has('choices'):
			element = current['choices']
		elif current.has('then') and current['then'] is Array:
			element = current['then']
		
		if element is Array and index < len(element):
			current = element[index]
		else:
			return {}
	return current

func jump_to(sub_dialog_name) -> void:
	if sub_dialog_name is String:
		var inner_jump = "%s.%s" % [parent_dialog, sub_dialog_name]
		if dialogs.has(inner_jump):
			current_dialog = inner_jump
			current_path = [0]
		elif dialogs.has(sub_dialog_name):
			parent_dialog = sub_dialog_name
			current_dialog = sub_dialog_name
			current_path = [0]
		else:
			_clear_cursor()
			printerr("wtf is '%s'?" % sub_dialog_name)

func _clear_cursor() -> void:
	parent_dialog = ''
	current_dialog = ''
	current_path = []

func _build_node(node) -> Dictionary:
	if not node.has('text'):
		return {}
	var next = _build_text_node(node.text)
	if node.has('choices'):
		var choices = []
		var id = 0
		for choice in node['choices']:
			id += 1
			var choice_path = current_path.duplicate()
			choice_path.push_back(id - 1)
			if choice.has('if') and not _if(choice['if'], choice_path):
				continue
			var choice_line = _build_text_node(choice.text)
			choice_line['id'] = id - 1
			choices.append(choice_line)
		if len(choices) > 0:
			next['choices'] = choices
			return next
		else:
			return {}
	return next

func _build_text_node(textes) -> Dictionary:
	var text = _do_build_text(textes)
	var node = {
		'text': text.format(variables, '$_')
	}
	match node['text'].split(':', false, 1) as Array:
		[var _text_part]:
			node['text'] = _text_part
		[var _who, var _text_part]:
			node['who'] = _who.strip_edges()
			node['text'] = _text_part

	match node['text'].split('#', false, 1) as Array:
		[var _text_part]:
			node['text'] = _text_part
		[var _text_part, var _tags]:
			node['text'] = _text_part
			node['tags'] = []
			for tag in _tags.split('#', false):
				tag = tag.strip_edges()
				if tag.begins_with('!'):
					emit_signal("event_emitted", parent_dialog, tag.right(1))
				node['tags'].push_back(tag)

	return node

func _do_build_text(textes) -> String:
	var s = ""
	for part in textes:
		if part is String:
			s += part
		elif part.has('if') and _if(part['if']):
			s += _do_build_text(part.text)
	return s

func dialog_list() -> Array:
	return dialogs.keys()

func variables() -> Dictionary:
	return variables

func set_var(variable_key: String, value) -> void:
	variables[variable_key] = value

func get_var(variable_key):
	if variables.has(variable_key):
		return variables[variable_key]
	return null

func bind_function(function_name: String, node, function) -> void:
	pass

func _get_configuration_warning() -> String:
	if not file_valid:
		return "This node requires the JSON dialog's file in order to work."
	return ""

func _load_new_dialog_file(files: Array) -> void:
	dialog_files = files
	file_valid = true
	_reset_node()
	for f in files:
		var file = File.new()
		var error = file.open(f, file.READ)
		if error:
			file_valid = false
			return
		var json = JSON.parse(file.get_as_text()).result
		if json.has("dialogs"):
			_merge_dialogs(json)

func _reset_node() -> void:
	variables = {}
	dialogs = {}
	visited = {}

func _merge_dialogs(json: Dictionary) -> bool:
	var json_dialogs = json.get("dialogs")
	var json_variables = json.get("variables")
	for dialog_key in json_dialogs:
		if dialogs.has(dialog_key):
			printerr("dialog key '%s' already exists" % dialog_key)
			return false
		dialogs[dialog_key] = json_dialogs[dialog_key]
	for variable in json_variables:
		if not variables.has(variable):
			variables[variable] = json_variables[variable]
	return true

func _op(opperation) -> void:
	match opperation:
		['=', var key, var value]:
			variables[key] = value
		['+', var key, var value]:
			variables[key] += value
		['-', var key, var value]:
			variables[key] -= value
		['*', var key, var value]:
			variables[key] *= value

func _if(predicate, path = []) -> bool:
	match predicate:
		['test', var key, var op, var value]:
			if not variables.has(key):
				return false
			else:
				var variable = variables[key]
				match op:
					'eq':
						return variable == value
					'ne':
						return variable != value
					'lt':
						return variable < value
					'le':
						return variable <= value
					'gt':
						return variable > value
					'ge':
						return variable >= value
			return false
		['count_lower', var nth]:
			return not visited.has(path) or visited[path] < nth
		['visited', var dialog_key]:
			return visited.has(dialog_key) and visited[dialog_key] > 0
		['not_visited', var dialog_key]:
			return not visited.has(dialog_key) or visited[dialog_key] == 0
	return false
