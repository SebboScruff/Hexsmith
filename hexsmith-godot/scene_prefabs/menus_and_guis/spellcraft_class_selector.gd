# Control Cursor Movement, UI-based hit detection, and resultant Class Selection
# For use in the Spellcrafting Menu.

extends Control

# list of the Spell Classes used in Suffix generation.
enum SPELL_CLASSES{NONE, TELUMANCY, MOTOMANCY, INSTRUMANCY}
 # the Selector's current class needs to be available everywhere.
@export var current_class : SPELL_CLASSES

# Define which colours the cursor becomes when in the appropriate Selection Zone
const telumancy_cursor_colour = Color(1,0,1,1) # Magenta
const motomancy_cursor_colour = Color(0,1,1,1) # Cyan
const instrumancy_cursor_colour = Color(1,1,0,1) # Yellow

@onready var cursor_img: TextureRect = $class_selection_cursor

# TODO Eventually include Mouse Off Callbacks (maybe)
@onready var telumancy_button: TextureButton = %telumancy_button
@onready var motomancy_button: TextureButton = %motomancy_button
@onready var instrumancy_button: TextureButton = %instrumancy_button

func _ready():
	# reset whenever this object is loaded.
	current_class = SPELL_CLASSES.NONE # SPELL_CLASSES.NONE will basically never be used other than here

# Sync the on-screen cursor to the user's mouse movements
# Needs a bit of adjustment at the end because the image's transform anchor
# is in the topleft rather than the middle.
func _input(event):
	if event is InputEventMouseMotion:
		cursor_img.set_global_position(event.position - (cursor_img.get_rect().size/2))
	# TODO Additional input idea for finishing a spell:
	# - Hold down Mouse1 to make 4 buttons around the cursor
	# - Each button is associated with a spell slot
	# Hover over a button and release Mouse1 as an alternative input for Craft and Assign

func _process(_delta: float) -> void:
	# Change Cursor Color depending on currently selected School.
	# Eventually this will also change the shape of the cursor for accessibility
	match(current_class):
		SPELL_CLASSES.NONE:
			cursor_img.self_modulate = Color(1,1,1,1) # default to white when first opening the menu
		SPELL_CLASSES.TELUMANCY:
			cursor_img.self_modulate = telumancy_cursor_colour
		SPELL_CLASSES.MOTOMANCY:
			cursor_img.self_modulate = motomancy_cursor_colour
		SPELL_CLASSES.INSTRUMANCY:
			cursor_img.self_modulate = instrumancy_cursor_colour

func set_current_class(new_class:SPELL_CLASSES):
	current_class = new_class

# Button Hover Callbacks
func _on_telumancy_button_mouse_entered() -> void:
	set_current_class(SPELL_CLASSES.TELUMANCY)

func _on_motomancy_button_mouse_entered() -> void:
	set_current_class(SPELL_CLASSES.MOTOMANCY)

func _on_instrumancy_button_mouse_entered() -> void:
	set_current_class(SPELL_CLASSES.INSTRUMANCY)
