## Supabase client.
extends "endpoint.gd"

const Endpoint = preload("endpoint.gd")
const Auth = preload("auth.gd")
const PGMeta = preload("pg_meta.gd")
const Rest = preload("rest.gd")
const Storage = preload("storage.gd")
const Realtime = preload("realtime.gd")

## The auth end-point.
var auth : Auth
## The pgmeta end-point.
var pg : PGMeta
## The PostgREST end-point.
var rest : Rest
## The storage end-point.
var storage : Storage
## The realtime end-point.
var realtime : Realtime

## Creates a new Supabase client.
func _init(node: Node, url: String, api_key: String, tls_options: TLSOptions = null):
	var http_url := url.trim_suffix("/")
	var ws_url := ""
	if not http_url.is_empty():
		if not http_url.begins_with("http://") and not http_url.begins_with("https://"):
			http_url = "http://" + http_url
		ws_url = "ws%s/realtime/v1/websocket" % http_url.substr(4)

	identity = Identity.new(api_key)
	identity.identity_changed.connect(_identity_changed)
	client = Client.new(node, http_url, {
		"apikey": api_key,
		"Authorization": "Bearer " + api_key
	}, tls_options)
	auth = Auth.new(client, "/auth/v1", identity)
	pg = PGMeta.new(client, "/pg", identity)
	rest = Rest.new(client, "/rest/v1", identity)
	storage = Storage.new(client, "/storage/v1", identity)
	realtime = Realtime.new(node, ws_url, identity, tls_options)


func _identity_changed():
	client.set_header("Authorization", "Bearer " + identity.get_access_token())


## Gets the identity.
func get_identity() -> Identity:
	return identity

## Gets the REST client.
func get_rest_client() -> Client:
	return client
