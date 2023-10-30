extends Resource
class_name ServerSettings
## Bypasses certificate check on dev mode
@export var dev : bool = false;
## Server Address and Port. ws:// prefix indicates websocket connection. wss:// indicates websocket secure
@export var Address: String = "localhost"
@export var Port: int = 5511
var AddressPortFormat = "%s:%s"
var ServerAddress = AddressPortFormat %[Address,Port]

## World is rendered 0.1s in the past to allow interpolation
@export var WorldStateOffset = 0.10
## Client sends a delay request 0.05s
@export var DelayRequestTickRate = 0.5;

