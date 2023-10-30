extends CharacterBody3D
class_name Player;

@export var friction : float = 0.2;
@export var rotation_speed = 10
@export var player_speed = 8

func _ready():
	ClientTimer.onTick.connect(DefinePlayerState);
	
func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	velocity += Vector3.DOWN * ProjectSettings.get_setting("physics/3d/default_gravity");
	var input_direction = 	Input.get_vector("ui_left", "ui_right", "ui_up","ui_down")
	if input_direction:
		velocity = Vector3(input_direction.x, 0, input_direction.y) * player_speed
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x,velocity.z),delta * rotation_speed);
	else:
		velocity -= velocity * friction
	move_and_slide()
	
# Encode the player state and send it to the server
func DefinePlayerState():
	var playerState = Player_data.new(
		Time.get_unix_time_from_system(),
		position,
		rotation
		).encode();
	Server.SendPlayerState.rpc(playerState);
