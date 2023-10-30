extends Camera3D
@onready var player = get_node("../Player");
@onready var initialOffset = Vector3(position.x, 0, position.z);

@export var min_bounds: Vector2
@export var max_bounds: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var targetPosition = Vector3(player.position.x, position.y, player.position.z) + initialOffset;
	targetPosition = constrain_position(targetPosition);
	position = Vector3(targetPosition) 


func constrain_position(pos: Vector3) -> Vector3:
	pos.x = clamp( pos.x, min_bounds.x, max_bounds.x) 
	pos.z = clamp( pos.z,min_bounds.y, max_bounds.y)
	return pos
