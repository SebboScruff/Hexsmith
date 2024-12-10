# Boilerplate for a basic conical trail: 
# Adds points to an instanced curve based on the parent object's global position.
# and contains a slow, fade-out object deletion.

class_name Trail
extends Line2D

const MAX_POINTS := 200 # cap the maximum points in the curve for performance and visual tail length
@onready var curve := Curve2D.new()

func _process(delta: float) -> void:
	# Every frame, add a new point to the curve where the moving object is
	curve.add_point(get_parent().global_position)
	# If there are too many points along the curve, remove the oldest one
	if(curve.get_baked_points().size() > MAX_POINTS):
		curve.remove_point(0)
	# Assign the points on the curve into this Trail's points.
	# NOTE: points here is Trail.points (this class extends Line2D)
	points = curve.get_baked_points()
	
# Slow fade-out into destroy object
func fade_out(time:float) -> void:
	set_process(false)
	var tween := get_tree().create_tween()
	# Reduce the Self-Modulate Alpha (aka this object's transparency) to
	# 0 over the given number of seconds.
	tween.tween_property(self, "modulate:a", 0.0, time)
	await tween.finished
	# Destroy this object after the tween fade-out is finished
	queue_free()

# So that Trail.create_new_trail can be called from anywhere.
static func create_new_trail():
	var scn := preload("res://scene_prefabs/spell_objects/effects/trail.tscn")
	return scn.instantiate()
