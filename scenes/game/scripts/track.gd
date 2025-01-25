class_name Track extends Resource

## Name of the track
@export var name : String

## Reference to the scene of this given track
@export var track_scene: PackedScene

## String representation of the for debugging
func _to_string() -> String:
	return "<Track:%s, scene:%s>" % [name, track_scene]
