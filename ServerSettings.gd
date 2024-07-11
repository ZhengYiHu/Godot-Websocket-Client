extends Resource
class_name ServerSettings
## Bypasses certificate check on dev mode
@export var use_ssl_certificate : bool = false;
## Server Address and Port. ws:// prefix indicates websocket connection. wss:// indicates websocket secure
@export var Address: String = "localhost"
@export var Port: int = 5511
@export var cert: X509Certificate;

## World is rendered 0.1s in the past to allow interpolation
@export var WorldStateOffset = 0.10
## Client sends a delay request 0.05s
@export var DelayRequestTickRate = 0.5;
## Client sends a physics packet every 0.05s
@export var PhysicsTickRate = 0.05;
