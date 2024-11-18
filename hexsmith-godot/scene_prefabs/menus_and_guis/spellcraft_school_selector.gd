# Control Cursor Movement, UI-based hit detection, and resultant Class Selection
# For use in the Spellcrafting Menu.

extends Control

enum SPELL_CLASSES{NONE, TELUMANCY, MOTOMANCY, INSTRUMANCY}
var current_class : SPELL_CLASSES

# Define which colours the cursor becomes when in the appropriate Selection Zone
const telumancy_cursor_colour = Color(1,0,1,1) # Magenta
const motomancy_cursor_colour = Color(0,1,1,1) # Cyan
const instrumancy_cursor_colour = Color(1,1,0,1) # Yellow

@onready var cursor_img: TextureRect = $class_selection_cursor

# TODO holy shit this is ugly, surely its better to just use buttons
# and a hover-over callback
@onready var telumancy_collision_area: Area2D = %telumancy_collision_area
@onready var motomancy_collision_area: Area2D = %motomancy_collision_area
@onready var instrumancy_collision_area: Area2D = %instrumancy_collision_area


func _ready():
	# reset whenever this object is loaded.
	current_class = SPELL_CLASSES.NONE # SPELL_CLASSES.NONE will basically never be used other than here


# Sync the on-screen cursor to the user's mouse movements
# Needs a bit of adjustment at the end because the image's transform anchor
# is in the topleft rather than the middle.
func _input(event):
	if event is InputEventMouseMotion:
		cursor_img.set_global_position(event.position - (cursor_img.get_rect().size/2))

func _process(delta: float) -> void:
	# Change Cursor Color depending on currently selected School.
	# Eventually this will also change the shape of the cursor for accessibility
	match(current_class):
		SPELL_CLASSES.NONE:
			cursor_img.self_modulate = Color(1,1,1,1)
		SPELL_CLASSES.TELUMANCY:
			cursor_img.self_modulate = telumancy_cursor_colour
		SPELL_CLASSES.MOTOMANCY:
			cursor_img.self_modulate = motomancy_cursor_colour
		SPELL_CLASSES.INSTRUMANCY:
			cursor_img.self_modulate = instrumancy_cursor_colour

func set_current_class(new_class:SPELL_CLASSES):
	current_class = new_class

#  Check collisions on the cursor object's area2D
func _on_cursor_collision_object_area_entered(area: Area2D) -> void:
	match(area):
		telumancy_collision_area:
			set_current_class(SPELL_CLASSES.TELUMANCY)
		motomancy_collision_area:
			set_current_class(SPELL_CLASSES.MOTOMANCY)
		instrumancy_collision_area:
			set_current_class(SPELL_CLASSES.INSTRUMANCY)
		_: # If we somehow end up in a default case
			print("Unexpected collision on Class Selection Cursor")
			set_current_class(SPELL_CLASSES.NONE)
	pass # Replace with function body.
