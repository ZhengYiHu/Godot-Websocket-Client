class_name World_data;

var time = 0.0;
var playersData = {}; # Collection of all players data

func _init(t, d):
	time = t;
	playersData = d;

# save in dictionary to minimize the amount of data sent
func encode():
	# encode all players data before encoding world data
	var encodedPlayersData = {};
	for playerId in playersData.keys():
		encodedPlayersData[playerId] = playersData[playerId].encode();
		
	var payload = {
		'T' : time,
		'D' : encodedPlayersData
	};
	return var_to_bytes(payload);

static func decode(bytes):
	bytes = bytes_to_var(bytes);
	var decodedPlayersData = {};
	# decode all players data before decoding world data
	if(bytes['D']):
		for playerData in bytes['D'].keys():
			decodedPlayersData[playerData] = Player_data.decode(bytes['D'][playerData]);
	
	return World_data.new(bytes['T'],decodedPlayersData);
