tool
class_name DialogSystem
extends Node

export(Array, String, FILE) var dialog_files := [] setget _load_new_dialog_file

var file_valid = false
var variables := {}
var dialogs := {}
var visited := []

func start_dialog(key: String) -> void:
	pass

func next() -> Dictionary:
	return {}

func choice_next(index: int) -> Dictionary:
	return {}

func dialogs_list() -> Array:
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
	visited = []

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
	print(dialogs_list())
	return true

func _op(opperation) -> void:
	match opperation:
		['+', var key, var value]:
			variables[key] += value
		['-', var key, var value]:
			variables[key] -= value
		['*', var key, var value]:
			variables[key] *= value

func _if(predicate) -> bool:
	match predicate:
		['visited', var dialog_key]:
			return visited.has(dialog_key)
		['not_visited', var dialog_key]:
			return not visited.has(dialog_key)
	return false
