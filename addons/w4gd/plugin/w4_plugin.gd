@tool
extends EditorPlugin

const BASE = "w4games/w4rm"
const URL = "url"
const KEY = "key"
const PROFILES = "profiles"
const CURRENT_PROFILE = "current"

const W4ProjectSettings = preload("w4_project_settings.gd")

const W4PluginMainScene = preload("editor/w4_dashboard.tscn")
const W4PluginMainScript = preload("editor/w4_dashboard.gd")
const W4SettingsScript = preload("res://addons/w4gd/plugin/editor/w4_workspace_settings.gd")

# Icon
const W4Icon = preload("icons/w4icon.svg")

#region W4Debugger
class W4Debugger extends EditorDebuggerPlugin:

	var run_script_path := ""
	var run_script_data := {}

	func _has_capture(prefix) -> bool:
		return prefix == "w4"


	func _capture(message, data, session_id) -> bool:
		if message == "w4:ready":
			run_script(session_id)
			return true
		return false


	func run_script(session_id):
		if run_script_path.is_empty() or run_script_data.is_empty():
			return
		get_session(session_id).send_message("w4:run", [run_script_path, run_script_data.duplicate()])
		run_script_path = ""
		run_script_data.clear()
#endregion

#region EditorSettings

func _get_s(key, def=null):
	var fk = "%s/%s" % [BASE, key]
	return ProjectSettings.get_setting(fk) if ProjectSettings.has_setting(fk) else def


func _get_m(key, def=null):
	var es = get_editor_interface().get_editor_settings()
	return es.get_project_metadata("w4games", key, def)


func _set_s(key, value, save=true):
	var fk = "%s/%s" % [BASE, key]
	ProjectSettings.set_setting(fk, value)
	if save:
		ProjectSettings.save()


func _set_m(key, value):
	var es = get_editor_interface().get_editor_settings()
	es.set_project_metadata("w4games", key, value)


func _check_set_metadata(key, value):
	if typeof(_get_m(key)) != typeof(value):
		_set_m(key, value)


func _init_settings():
	W4ProjectSettings.add_project_settings()

	_check_set_metadata(PROFILES, [])
	_check_set_metadata(CURRENT_PROFILE, "default")

#endregion

#region Profiles

func _get_profiles() -> Array:
	var profiles = _get_m(PROFILES, [])
	if typeof(profiles) == TYPE_ARRAY:
		return profiles.duplicate(true)
	return []


func _set_profiles(profiles: Array):
	for p in profiles:
		if "name" not in p or "url" not in p or "key" not in p:
			push_error("Invalid profile: %s" % [p])
			return
	_set_m(PROFILES, profiles)


func _profile_edited(profile: String, key: String, value: String):
	if profile == "default":
		_set_s(key, value)
	else:
		_set_profiles(settings.profiles)


func _profile_add(profile: String):
	_set_profiles(settings.profiles)


func _profile_delete(profile: String):
	_set_profiles(settings.profiles)


func _profile_renamed(profile: String, to: String):
	_set_profiles(settings.profiles)


func _profile_selected(profile: String):
	_set_m(CURRENT_PROFILE, profile)

#endregion

var debugger : W4Debugger
var main_scene : W4PluginMainScript
var settings : W4SettingsScript
var sdk : W4Client
var main_icon : Texture2D

func _on_workspace_settings_changed(config: Dictionary):
	if sdk == null:
		return
	sdk.client.client.base_url = config.url
	sdk.client.client.set_header("apikey", config.key)
	sdk.identity.set_access_token(config.key)
	OS.set_environment("W4_URL", config.url)
	OS.set_environment("W4_KEY", config.key)


func _run_script(script_path):
	if settings == null or sdk == null:
		return
	var config = settings.get_config()
	debugger.run_script_path = script_path
	debugger.run_script_data = {"url": config["url"], "key": config["key"], "service_key": sdk.identity.access_token}
	var scene = main_scene.scene_file_path.get_base_dir() + "/../w4_script_loader.tscn"
	get_editor_interface().play_custom_scene(scene)


#region PluginOverrides

func _enter_tree() -> void:
	_init_settings()

	add_autoload_singleton("W4GD", "res://addons/w4gd/w4gd.gd")

	var icon = _get_plugin_icon()
	add_custom_type("W4AuthHelper", "Node", W4AuthHelper, icon)

	sdk = W4Client.new()
	add_child(sdk)

	debugger = W4Debugger.new()
	add_debugger_plugin(debugger)

	main_scene = W4PluginMainScene.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_scene)
	main_scene.sdk = sdk
	main_scene.editor_scale = get_editor_interface().get_editor_scale()
	main_scene.database.run_script.connect(_run_script)
	settings = main_scene.workspace_settings
	settings.profiles = _get_profiles()
	settings.current_profile = _get_m(CURRENT_PROFILE, "default")
	_on_workspace_settings_changed(settings.get_config()) # Setup the SDK with the current config
	settings.profile_edited.connect(_profile_edited)
	settings.profile_added.connect(_profile_add)
	settings.profile_deleted.connect(_profile_delete)
	settings.profile_renamed.connect(_profile_renamed)
	settings.profile_selected.connect(_profile_selected)
	settings.workspace_settings_changed.connect(_on_workspace_settings_changed)
	settings.refresh.call_deferred()
	main_scene.hide()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_scene == null:
		return
	main_scene.visible = visible


func _get_plugin_name():
	return "W4 Cloud"


func _get_plugin_icon():
	if main_icon != null:
		return main_icon
	main_icon = ImageTexture.create_from_image(W4Icon.get_image())
	main_icon.set_size_override(Vector2i(16, 16))
	return main_icon


func _exit_tree() -> void:
	remove_custom_type("W4AuthHelper")
	remove_debugger_plugin(debugger)
	if main_scene != null:
		main_scene.queue_free()
		main_scene = null

	if sdk != null:
		sdk.queue_free()
		sdk = null


#endregion
