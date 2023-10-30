extends Node

@onready var debugNode = get_node("/root/Game/DebugUI")
var Connected = false;
var ConnectedFormat = "Connected: %s"
var Delay : float = 0.0;
var Delta : float = 0.0;
var DeltaLatency : float = 0.0;
var DelayFormat = "Delay: %d ms. Delta: %d ms. DeltaLatency: %d ms"
var BufferCount : float = 0.0;
var BufferCountFormat = "World Buffer Count: %d"
var CurrentTime : int = 0;
var CurrentTimeFormat = "Current Time: %s" # Client time considering server delay
var RenderTime : int = 0;
var RenderTimeFormat = "Render Time:  %s" # Time which the world is rendered in 
var ActualTime : int = 0;
var ActualTimeFormat = "System Time:    %s" # Device's system time

func _process(_delta):
	# Shift + F to toggle visibility
	if Input.is_action_just_pressed("Debug"):
		debugNode.visible = !debugNode.visible;
	debugNode.get_node("Connected").text = ConnectedFormat % str(Server.Connected);
	debugNode.get_node("Delay").text = DelayFormat % [(Delay * 1000),(Delta * 100), (DeltaLatency * 1000)];
	debugNode.get_node("BufferCount").text = BufferCountFormat % Server.worldStateBuffer.size();
	debugNode.get_node("CurrentTime").text = CurrentTimeFormat % formatDate(ClientTimer.clientClock);
	var renderWordTime = 0;
	if Server.worldStateBuffer.size() > 0:
		renderWordTime = Server.worldStateBuffer[0].time;
	
	debugNode.get_node("RenderedTime").text = RenderTimeFormat % formatDate(renderWordTime);
	debugNode.get_node("ActualTime").text = ActualTimeFormat % formatDate(Time.get_unix_time_from_system());

func formatDate(unixTime):
	var unixTimeInt: int = unixTime
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(unixTime)
	var ms: int = (unixTime - unixTimeInt) * 1000.0
	var dateString := "%s.%s.%s %s:%s:%s:%s" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, ms]
	return dateString
