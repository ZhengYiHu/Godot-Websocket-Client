extends Node

var serverSettings = preload("res://ServerSettings.tres");

var AddressPortFormat = "%s:%s"
var ServerAddress = AddressPortFormat %[serverSettings.Address,serverSettings.Port]

var peer = WebSocketMultiplayerPeer.new();
var lastWorldState = 0;
var worldStateBuffer = [];
## If the current world state was already being evaluated
var worldStateWasEvaluated = false;

var Connected: bool:
	get:
		return peer.get_connection_status() == 2;

@onready var gameNode = get_parent().get_node_or_null("Game");
@onready var sceneNode = gameNode.get_node("GameScene") if gameNode != null else null

func _ready():
	Connect();
	if !Connected:
		# Try to connect to the server every 5 seconds, if succeds, stop the timer
		CreateTimer(5, Connect, multiplayer.connected_to_server);

## Create the client peers and connect to the server address and port
func Connect():
	multiplayer.connected_to_server.connect(ConnectedToServer)
	multiplayer.server_disconnected.connect(DisconnectedFromServer)
	multiplayer.connection_failed.connect(ConnectionFailed);
	
	var error;
	if serverSettings.use_ssl_certificate:
		error = peer.create_client(serverSettings.ServerAddress, TLSOptions.client(serverSettings.cert));
	else:
		error = peer.create_client(ServerAddress);
	print("Connecting to " + ServerAddress);
	if error:
		print("Error: "+ str(error));
		return;
	multiplayer.set_multiplayer_peer(peer);
	
## Called when THIS client is connected to the server
func ConnectedToServer():
	print("Player: "+str(multiplayer.get_unique_id())+ " Connected to server");
	sceneNode.get_node("Player").name = str(multiplayer.get_unique_id());
	# Start Timer that sends tick packets
	ClientTimer.ticking = true;
	# Get server time 
	RequestServerTime.rpc(Time.get_unix_time_from_system());
	# Create a Timer that calculates latency
	CreateTimer(serverSettings.DelayRequestTickRate, DetermineLatency, null);
	
## Called when THIS client is disconnected from the server
func DisconnectedFromServer():
	print("Player: "+str(multiplayer.get_unique_id())+" Disconnected from server");
	
func ConnectionFailed():
	print("Connection failed");

@rpc("any_peer","unreliable_ordered")
func SendPlayerState(_playerState):
	pass;

## Process the world state after server sends one over
@rpc("authority","unreliable_ordered")
func ReceiveWorldState(worldState):
	worldState = World_data.decode(worldState);
	# Only run if the world state received is the latst
	if worldState.time > lastWorldState:
		lastWorldState = worldState.time
		worldStateBuffer.append(worldState)

## Build a world buffer to interpolate
func _physics_process(_delta):
	var renderTime = ClientTimer.clientClock - serverSettings.WorldStateOffset;
	if worldStateBuffer.size() > 1:
		worldStateWasEvaluated = true;
		# Remove past world states
		while worldStateBuffer.size() > 2 and renderTime > worldStateBuffer[1].time:
			worldStateBuffer.remove_at(0);
			worldStateWasEvaluated = false;
			
		var lerpValue = inverse_lerp(worldStateBuffer[0].time,worldStateBuffer[1].time, renderTime);
		
		for player in worldStateBuffer[1].playersData:
			# Check if the player is present in the previous world state
			if not worldStateBuffer[0].playersData.has(player):
				continue;
			# Update player properties
			if gameNode.has_node(str(player)):
				# Set lerped properties to the players
				var pastPlayerData = worldStateBuffer[0].playersData[player];
				var futurePlayerData = worldStateBuffer[1].playersData[player];
				var interpolatedPosition = lerp(pastPlayerData.position, futurePlayerData.position,lerpValue);
				var interpolatedRotation = lerp(pastPlayerData.rotation, futurePlayerData.rotation,lerpValue);
				gameNode.get_node(str(player)).SetTransform(interpolatedPosition, interpolatedRotation);
			# Create new player if not present and are not the player itself
			else:
				if multiplayer.get_unique_id() != player:
					sceneNode.SpawnNewPlayer(player);

@rpc("any_peer")
func RequestServerTime(_clientTime):
	pass;

@rpc("authority")
func ReceiveServerTime(serverTime, initialClientTime):
	ClientTimer.CorrectClientClock(serverTime,initialClientTime);

func CreateTimer(waitTime: float, OnTimeout : Callable, DestroyTimer):
	
	var timer = Timer.new();
	timer.wait_time = waitTime;
	timer.autostart = true;
	timer.timeout.connect(OnTimeout);
	if DestroyTimer:
		DestroyTimer.connect(func(): timer.queue_free());
	self.add_child(timer);

## Function to call rpc to hook to a signal
func DetermineLatency():
	RequestDetermineLatency.rpc(Time.get_unix_time_from_system());

@rpc("any_peer")
func RequestDetermineLatency(_clientTime):
	pass
	
@rpc("authority")
func ReceiveDetermineLatency(initialClientTime):
	ClientTimer.DetermineLatency(initialClientTime)
