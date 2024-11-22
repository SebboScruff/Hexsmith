# Custom container class for eventual use in the Active Mana Display (and possibly 
# in the Spellcraft Menu.
# Requirements:
# # If only 1 child: behave as normal CenterContainer, placing it in the middle
# # of the container
# # ---
# # If more than 1 child, place all children equidistant from BOTH the container
# # center AND all other children (as far as possible - will not work if 360%n(children) != 0
# # This will result in all children being distributed in a radial pattern around the container's center
# ---
# https://github.com/godotengine/godot/blob/419e713a29f20bd3351a54d1e6c4c5af7ef4b253/scene/gui/center_container.cpp
# for existing examples

extends Container

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			pass

func _get_minimum_size() -> Vector2:
	return Vector2.ZERO
