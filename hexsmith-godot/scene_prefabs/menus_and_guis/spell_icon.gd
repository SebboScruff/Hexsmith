class_name SpellIcon extends Control

@onready var icon: TextureRect = %icon
@onready var frame: TextureRect = %frame
@onready var hotkey: TextureRect = %hotkey
@onready var cooldown: TextureProgressBar = %cooldown
@onready var active_highlight: TextureRect = %active_highlight


func get_icon() -> TextureRect:
	return icon
func get_frame() -> TextureRect:
	return frame
func get_cooldown_indicator() -> TextureProgressBar:
	return cooldown

func set_icon(new_icon:CompressedTexture2D) -> void:
	icon.texture = new_icon
func set_frame(new_frame:CompressedTexture2D) -> void:
	frame.texture = new_frame

func update_cd_visual(_max:float, _current:float) -> void:
	cooldown.max_value = _max
	cooldown.value = _current

func set_highlight_state(_state:bool) -> void:
	active_highlight.set_visible(_state)
	active_highlight.set_process(_state)

# Pass in corresponding x, y, w, h values for a new region in the hotkey
# images texture atlas.
@warning_ignore("unused_parameter")
func set_hotkey_visual(new_x:int, new_y:int, new_w:int, new_h:int) -> void:
	# TODO Use the incoming atlas co-ordinates to change the visual hotkey
	# on the spell icon.
	# Will require creating a different AtlasTexture resource per instance of this class
	# so that the changes only affect one slot icon at a time.
	pass
