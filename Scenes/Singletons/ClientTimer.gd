extends Node

var previousTick;
var clientClock : float = 0;
var latency = 0;
var deltaLatency = 0;
var latencyArray = [];

var ticking = false;
signal onTick;

func _ready():
	previousTick = Time.get_unix_time_from_system();
	clientClock = Time.get_unix_time_from_system();
	
func _physics_process(delta):
	# Handle client tick signal
	if Time.get_unix_time_from_system() - previousTick > GameConfigs.PhysicsTickRate && ticking:
		previousTick = Time.get_unix_time_from_system();
		onTick.emit();
		
	# Keep client clock up to date
	clientClock = Time.get_unix_time_from_system() + deltaLatency;
	Debug.Delta = delta;
	Debug.DeltaLatency = deltaLatency;
	deltaLatency = 0;

# Get initial latency and correct the clock value with it
func CorrectClientClock(serverTime,initialClientTime):
	latency = (Time.get_unix_time_from_system() - initialClientTime)/2;
	clientClock = serverTime + latency;

func DetermineLatency(initialClientTime):
	# Store latencies in an array to determine the average over time
	latencyArray.append((Time.get_unix_time_from_system() - initialClientTime)/2);
	if latencyArray.size() == 9 :
		var totalLatency = 0;
		latencyArray.sort();
		var midPoint = latencyArray[4];
		for i in range(latencyArray.size() - 1, -1, -1):
			# Remove outliers
			if latencyArray[i] > (2 * midPoint) and latencyArray[i] > 20:
				latencyArray.remove_at(i);
			else :
				totalLatency += latencyArray[i];
		# Get average latency
		deltaLatency = (totalLatency/ latencyArray.size()) - latency;
		Debug.Delay = latency;
		latency = (totalLatency/ latencyArray.size());
		latencyArray.clear();
