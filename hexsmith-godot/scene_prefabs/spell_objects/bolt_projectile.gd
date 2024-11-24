extends Area2D

@export var travel_speed:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Move Forward based on this objects forward vector.
	var move_dir = Vector2.LEFT.rotated(self.rotation)
	self.position += move_dir * delta * travel_speed

func _on_body_entered(body: Node2D) -> void:
	# Find combat entity of body (if any)
	# Deal damage based on this bolt's colour input
	# Destroy this bolt
	queue_free()
