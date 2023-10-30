class_name Player_data;

var time = 0.0 # Time when the packet is sent
var position = Vector3.ZERO # Position of the player
var rotation =  Vector3.ZERO # Roation of the player

func _init(t, pos, rot):
	time = t;
	position = pos;
	rotation = rot;

# get a data structure to minimize the amount of data sent
func encode():
	var payload = {
		'T' : time,
		'P' : position,
		'R' : rotation
	};
	return var_to_bytes(payload);

static func decode(bytes):
	bytes = bytes_to_var(bytes);
	return Player_data.new(bytes['T'],bytes['P'],bytes['R']);
