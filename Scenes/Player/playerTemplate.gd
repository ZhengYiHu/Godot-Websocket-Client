extends Node3D
class_name	PlayerTemplate

var velocity;
var previousPos;
var initialized = false;

func SetPosition(newPosition: Vector3):
	position = newPosition;

func SetRotation(newRotation: Vector3):
	rotation = newRotation;

func SetTransform(newPosition, newRotation):
	SetPosition(newPosition);
	SetRotation(newRotation);

func _ready():
	previousPos = position;
	initialized = true;
	
func _physics_process(delta):
	if !initialized:
		return;
	velocity = abs(position - previousPos)/delta;
	previousPos = position;
