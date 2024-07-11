@tool
extends Control

const W4EditorServers = preload("w4_server_uploader.gd")
const W4EditorDatabase = preload("w4_editor_database.gd")

const ADMIN_ROLE := "service_role"

var sdk: W4Client : set = _set_sdk
var editor_scale := 1.0 : set = _set_editor_scale

@onready var auth_helper := $W4AuthHelper as W4AuthHelper
@onready var workspace_settings := $SplitContainer/WorkspaceSettings
@onready var servers := $SplitContainer/Main/MarginContainer/TabContainer/Home/VBoxContainer/Servers as W4EditorServers
@onready var database := $SplitContainer/Main/MarginContainer/TabContainer/Home/VBoxContainer/Database as W4EditorDatabase
@onready var auth_ui := $SplitContainer/Auth as Control
@onready var main_ui := $SplitContainer/Main as Control
@onready var auth_error_label := $SplitContainer/Auth/LoginScreen/Vertical/ErrorLabel as Label
@onready var auth_email_input := $SplitContainer/Auth/LoginScreen/Vertical/EmailInput as LineEdit
@onready var auth_password_input := $SplitContainer/Auth/LoginScreen/Vertical/PasswordInput as LineEdit
@onready var web_dashboard_link := $SplitContainer/Auth/LoginScreen/Vertical/Web/LinkButton as LinkButton


func _ready():
	_set_sdk(sdk)
	if not Engine.is_editor_hint():
		_set_editor_scale(editor_scale)


func _set_sdk(value: W4Client):
	sdk = value
	if auth_helper != null:
		auth_helper.sdk = sdk
	if servers != null:
		servers.sdk = sdk
	if database != null:
		database.sdk = sdk

	_update_login_state()
	_update_dashboard_link()


func _set_editor_scale(value: float):
	editor_scale = value
	var min_size = Vector2(400, 0) * editor_scale
	if workspace_settings != null:
		workspace_settings.editor_scale = editor_scale
		workspace_settings.custom_minimum_size = Vector2(240, 0) * editor_scale
	if main_ui != null:
		main_ui.custom_minimum_size = min_size
	if auth_ui != null:
		auth_ui.custom_minimum_size = min_size


func _update_login_state():
	if sdk == null or auth_ui == null or main_ui == null:
		return
	if sdk.identity.role == ADMIN_ROLE:
		auth_ui.hide()
		main_ui.show()
	else:
		auth_ui.show()
		main_ui.hide()


func _on_visibility_changed():
	if sdk == null:
		return
	_update_login_state()
	_update_dashboard_link()


func _on_w_4_auth_helper_logged_out():
	auth_error_label.text = ""
	_update_login_state()


func _on_w_4_auth_helper_logged_in():
	var msg = "" if sdk.identity.role == ADMIN_ROLE else "Invalid user role: '%s'" % sdk.identity.role
	_set_login_message(msg, not msg.is_empty())
	_update_login_state()


func _set_login_message(message: String, error:=true):
	auth_error_label.text = message
	var color = Color.DARK_RED if error else Color.DARK_GREEN
	auth_error_label.add_theme_color_override("font_color", color)


func _on_login_input_submitted(_unused = ""):
	_set_login_message("Logging in...", false)
	auth_helper.login_email(
		auth_email_input.text,
		auth_password_input.text
	)


func _on_logout_pressed():
	auth_helper.logout()


func _on_workspace_settings_workspace_settings_changed(current_config: Dictionary):
	_update_dashboard_link.call_deferred()


func _update_dashboard_link():
	if sdk == null or web_dashboard_link == null:
		return
	var url := sdk.client.get_rest_client().base_url
	if url.is_empty():
		web_dashboard_link.uri = url
		return
	if not url.begins_with("http://") and not url.begins_with("https://"):
		url = "http://" + url
	url = url.trim_suffix("/") + "/dashboard/"
	web_dashboard_link.uri = url
