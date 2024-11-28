# Boilerplate for a basic conical trail: 
# Adds points to an instanced curve based on the parent object's global position.
# and contains a slow, fade-out object deletion.

class_name Trail
extends Line2D

const MAX_POINTS := 200 # cap the maximum points in the curve for performance
@onready var curve := Curve2D.new()

func _process(delta: float) -> void:
	curve.add_point(get_parent().global_position)
	if(curve.get_baked_points().size() > MAX_POINTS):
		curve.remove_point(0)
	points = curve.get_baked_points()
	
# Slow fade-out into destroy object
func fade_out(time:float) -> void:
	set_process(false)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, time)
	await tween.finished
	queue_free()

static func create_new_trail():
	var scn := preload("res://scene_prefabs/spell_objects/effects/trail.tscn")
	return scn.instantiate()
