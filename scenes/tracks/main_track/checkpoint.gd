extends Node3D

@onready var area_3d: Area3D = $Area3D

@export var checkpoint_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_3d.connect("body_entered", Callable(self, "_on_Area_body_entered"))


func _on_Area_body_entered(body: Node) -> void:
	if body.name == "Car":
		print("Checkpoint entered")
		body.checkpoint_id = checkpoint_id
		body.emit_signal("checkpoint_entered", checkpoint_id)
