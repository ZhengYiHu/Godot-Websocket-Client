@tool
extends Control

var editor_scale := 1.0 : set = _set_editor_scale
var url := ProjectSettings.get_setting("w4games/w4rm/url") as String
var key := ProjectSettings.get_setting("w4games/w4rm/key") as String
var current_profile := "default" :
	set(value):
		if profiles.filter(func(e): return e.name == value).is_empty():
			current_profile = "default"
		else:
			current_profile = value

var profiles := [
#	{
#		"name": "internal",
#		"url": "test",
#		"key": "testkey"
#	}
]

@onready var profiles_button := $VBoxContainer/Settings/HBoxContainer/ProfilesButton as OptionButton
@onready var delete_confirm_dialog := $DeleteConfirm as ConfirmationDialog
@onready var settings_tree := $VBoxContainer/Settings/SettingsTree as Tree

const COL_BTN = 1
const COL_VALUE = 1
const BTN_LOCK = 0
const BTN_ADD_REMOVE = 1


signal profile_edited(profile: String, key: String, value: String)
signal profile_deleted(profile: String)
signal profile_renamed(profile: String, to: String)
signal profile_added(profile: String)
signal profile_selected(profile: String)
signal workspace_settings_changed(current_config: Dictionary)


func _ready():
	if not Engine.is_editor_hint():
		refresh()
		_set_editor_scale(editor_scale)


func _set_editor_scale(value):
	editor_scale = value
	if settings_tree != null:
		settings_tree.set_column_custom_minimum_width(0, 60 * editor_scale)


func _mk_profile_btn() -> void:
	if profiles_button == null:
		return
	profiles_button.clear()
	var idx = 0
	var prof = profiles.duplicate()
	prof.push_front({"name": "default", "url": url, "key": key})
	for p in prof:
		profiles_button.add_item(p.name)
		profiles_button.set_item_metadata(idx, p.name)
		if current_profile == p.name:
			profiles_button.select(idx)
		idx += 1


func _mk_item(root: TreeItem, text: String, val:="") -> TreeItem:
	var it = root.create_child()
	it.set_text(0, text)
	it.set_text(1, val)
	it.set_selectable(0, false)
	return it


func _set_item_meta(item: TreeItem, meta1, meta2):
	item.set_metadata(0, meta1)
	item.set_metadata(1, meta2)


func _mk_tree() -> void:
	if settings_tree == null:
		return
	settings_tree.clear()
	settings_tree.set_column_expand(0, false)
	settings_tree.set_column_clip_content(1, true)
	var root = settings_tree.create_item()
	var prof = profiles.duplicate()
	prof.push_front({"name": "default", "url": url, "key": key})
	for p in prof:
		var k = p.name
		var pit := _mk_item(root, " ", k)
		pit.set_icon(0, get_theme_icon("WorldEnvironment", "EditorIcons"))
		_set_item_meta(pit, k, "")
		if k == current_profile:
			pit.set_icon(1, get_theme_icon("ImportCheck", "EditorIcons"))
		pit.add_button(COL_BTN, get_theme_icon("Lock", "EditorIcons"))
		if k == "default":
			pit.add_button(COL_BTN, get_theme_icon("New", "EditorIcons"))
		else:
			pit.add_button(COL_BTN, get_theme_icon("Remove", "EditorIcons"))
		pit.collapsed = k != current_profile
		var tmp
		tmp = _mk_item(pit, "Url", p["url"])
		_set_item_meta(tmp, k, "url")
		tmp = _mk_item(pit, "Key", p["key"])
		_set_item_meta(tmp, k, "key")


func _emit_settings_changed():
	workspace_settings_changed.emit(get_config())


func _edit_profile(profile: String, setting_name: String, value: String) -> void:
	if profile == "default":
		profile_edited.emit(profile, setting_name, value)
		if setting_name == "key":
			key = value
			profile_edited.emit(profile, setting_name, value)
			_emit_settings_changed()
		elif setting_name == "url":
			url = value
			profile_edited.emit(profile, setting_name, value)
			_emit_settings_changed()
		else:
			# Something is wrong
			_mk_tree.call_deferred()
	else:
		var found = profiles.filter(func(e): return e.name == profile)
		if found.size() and found.front().has(setting_name):
			found.front()[setting_name] = value
			profile_edited.emit(profile, setting_name, value)
			_emit_settings_changed()
		else:
			# Something is wrong
			_mk_tree.call_deferred()


func _select_profile(profile: String):
	var found = profiles.filter(func(e): return e.name == profile)
	current_profile = "default"
	if found.size():
		current_profile = profile
	profile_selected.emit(current_profile)
	_emit_settings_changed()
	_mk_tree.call_deferred()  # Remake tree to update the tick.


func _rename_profile(from: String, to: String) -> bool:
	if to == "default" or from == "default":
		return false
	var existing = profiles.filter(func(e): return e.name == to)
	if existing.size():
		return false
	var found = profiles.filter(func(e): return e.name == from)
	if found.size() == 0:
		_mk_tree.call_deferred()  # Something is wrong, better refresh the tree
		return false
	found.front().name = to
	profile_renamed.emit(from, to)
	_emit_settings_changed()
	_mk_profile_btn()  # Remake button with new names
	return true


func _delete_profile(profile):
	var found = profiles.filter(func(e): return e.name == profile)
	if found.size() == 0:
		return
	profiles.erase(found.front())
	if profile == current_profile:
		current_profile = "default"
		profile_selected.emit(current_profile)
	profile_deleted.emit(profile)
	_emit_settings_changed()
	refresh.call_deferred()


func _add_profile():
	var pname = "Profile"
	var idx = 0
	var names = profiles.map(func(e): return e.name)
	for i in range(0, 10):
		if (pname + str(i)) not in names:
			pname += str(i)
			break
	if pname == "Profile":
		return
	profiles.append({"name": pname, "url": "", "key": ""})
	profile_added.emit(pname)
	_emit_settings_changed()
	refresh.call_deferred()

func _on_settings_tree_button_clicked(item, column: int, id: int, mouse_button_index: int):
	if item == null:
		return
	var profile = item.get_metadata(0)
	if typeof(profile) != TYPE_STRING:
		return
	if column == COL_BTN:
		if id == BTN_LOCK:
			var childs = item.get_children()
			var was_editable = item.get_first_child().is_editable(1)
			if profile != "default":
				item.set_editable(1, not was_editable)
			for c in childs:
				c.set_editable(1, not was_editable)
			var icon = "Lock" if was_editable else "Unlock"
			item.set_button(COL_BTN, BTN_LOCK, get_theme_icon(icon, "EditorIcons"))
		elif id == BTN_ADD_REMOVE:
			if profile == "default":
				# Adds new profile
				_add_profile()
			else:
				# Asks to delete profile
				delete_confirm_dialog.exclusive = true
				delete_confirm_dialog.popup_centered()
				delete_confirm_dialog.dialog_text = "Delete profile '%s'?" % [profile]
				delete_confirm_dialog.get_cancel_button().grab_focus()
				delete_confirm_dialog.set_meta("profile", profile)


func _on_settings_tree_item_edited():
	if settings_tree == null:
		return
	var edited : TreeItem = settings_tree.get_edited()
	var edited_col = settings_tree.get_edited_column()
	if edited == null or edited_col < 0:
		return
	var setting_name = edited.get_metadata(1)
	var value = edited.get_text(edited_col)
	if setting_name == "":
		var profile = edited.get_metadata(0)
		if _rename_profile(profile, value):
			edited.set_metadata(0, value)
		else:
			edited.set_text(edited_col, profile)
	else:
		var profile = edited.get_parent().get_metadata(0)
		_edit_profile(profile, setting_name, value)


func _on_delete_confirm_confirmed():
	var profile = delete_confirm_dialog.get_meta("profile")
	if typeof(profile) != TYPE_STRING:
		return
	delete_confirm_dialog.remove_meta("profile")
	_delete_profile(profile)


func _on_profiles_button_item_selected(idx: int):
	var profile := profiles_button.get_item_metadata(idx) as String
	_select_profile(profile)


func get_config():
	var found = profiles.filter(func(e): return e.name == current_profile)
	if found.size():
		return found.front()
	return {"url": url, "key": key}


func refresh():
	_mk_tree()
	_mk_profile_btn()
