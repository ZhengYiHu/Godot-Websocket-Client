extends Node3D
# The object to represent other connected players
@onready var playerTemplate = preload("res://Scenes/Player/playerTemplate.tscn")

var instantiatedPlayers = []

func SpawnNewPlayer(id: int):
	if multiplayer.get_unique_id() == id:
		pass;
	else:
		var newPlayer;
		print("Spawned Other player "+ str(id))
		newPlayer = playerTemplate.instantiate();
			
		newPlayer.name = str(id);
		newPlayer.position = Vector3(0,0,0);
		get_parent().add_child(newPlayer);
		instantiatedPlayers.append(id);

func DespawnNewPlayer(id: int):
	print("Despawn "+ str(id))
	get_parent().get_node(str(id)).queue_free();
	instantiatedPlayers.erase(id);

func _physics_process(_delta):
	# Clean up extra players by despawning them if not present in the server anymore
	for playerInScene in instantiatedPlayers:
		if Server.worldStateBuffer.size() > 1:
			if not Server.worldStateBuffer[1].playersData.has(playerInScene) && multiplayer.get_unique_id() != playerInScene: 
				DespawnNewPlayer(playerInScene);
