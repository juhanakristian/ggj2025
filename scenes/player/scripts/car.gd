extends RigidBody3D

signal checkpoint_entered(checkpoint_id: int)
signal lap_completed()

signal toggle_controls(enabled: bool)

signal reset_car()

var checkpoint_id = 0
var next_checkpoint = 1
var total_checkpoints = 4

@onready var car_mesh = $CarMesh
@onready var body_mesh = $CarMesh/suv
@onready var ground_ray = $CarMesh/RayCast3D
@onready var right_wheel = $CarMesh/suv/wheel_right
@onready var left_wheel = $CarMesh/suv/wheel_left

@export var sphere_offset = Vector3.DOWN
@export var acceleration = 35.0
@export var steering = 18.0
@export var turn_speed = 4.0
@export var turn_stop_limit = 0.75
@export var speed_input = 0
@export var turn_input = 0
var body_tilt = 35
var controls_enabled = false

func _ready() -> void:
	connect("checkpoint_entered", Callable(self, "_on_checkpoint_entered"))
	connect("toggle_controls", Callable(self, "_on_toggle_controls"))
	connect("reset_car", Callable(self, "_on_reset_car"))

func _physics_process(_delta: float) -> void:
	car_mesh.position = position + sphere_offset

	if not controls_enabled:
		return

	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.z * speed_input)

func _process(delta):
	if not controls_enabled:
		return

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
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()

		var t = -turn_input * linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()

func _on_checkpoint_entered(checkpoint_id: int) -> void:
	print("Checkpoint entered: %d" % checkpoint_id)
	if checkpoint_id == next_checkpoint:
		next_checkpoint += 1
		print("Next checkpoint: %d" % next_checkpoint)

		if next_checkpoint > total_checkpoints:
			next_checkpoint = 1
			emit_signal("lap_completed")

func _on_toggle_controls(enabled: bool) -> void:
	controls_enabled = enabled


func _on_reset_car() -> void:
	position = Vector3(0, 1, 0)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	body_mesh.rotation = Vector3(0, deg_to_rad(-180), 0)
	car_mesh.global_transform.basis = Basis.IDENTITY
	next_checkpoint = 1
