extends RigidBody3D

@onready var car_mesh = $CarMesh
@onready var body_mesh = $CarMesh/suv2
@onready var ground_ray = $CarMesh/RayCast3D
@onready var right_wheel = $CarMesh/suv2/wheel_frontRight
@onready var left_wheel = $CarMesh/suv2/wheel_frontLeft


@export var sphere_offset = Vector3.DOWN
@export var acceleration = 35.0
@export var steering = 18.0
@export var turn_speed = 4.0
@export var turn_stop_limit = 0.75
@export var speed_input = 0
@export var turn_input = 0


func _physics_process(delta: float) -> void:
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.y * speed_input)


func _process(delta):
	if not ground_ray.is_colliding():
		return

	speed_input = Input.get_axis("brake", "accelerate") * acceleration
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)

	# Turn the wheels
	right_wheel.rotation.y = turn_input
	left_wheel.rotation.y = turn_input


	if linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.basis.orthonormalized()
