# Management for both ensuring correct Crosshair Positioning on the screen
# as well as hiding it from view if it is not moved for a while
extends TextureRect

@onready var disappear_timer: Timer = $disappear_timer
@onready var crosshair_visual: TextureRect = $"."

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		crosshair_visual.show() # make sure it's visible immediately when moved. This could probably be moved.
		crosshair_visual.set_global_position(event.position - (crosshair_visual.get_rect().size/2))

func _process(delta: float) -> void:
	pass # TODO Finish implementing hiding the visual after timer runs out.

func _on_disappear_timer_timeout() -> void:
	pass # TODO Finish implementing hiding the visual after timer runs out.
