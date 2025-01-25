extends Node

@onready var car: RigidBody3D = $"../Car"
var initial_offset: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_offset = self.global_transform.origin - car.global_transform.origin

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.global_transform.origin = car.global_transform.origin + initial_offset
