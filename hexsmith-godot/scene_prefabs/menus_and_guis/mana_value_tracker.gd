# Mana Tracker class for monitoring the player's usable Mana resources when
# casting spells. Not to be confused with the Spellcrafting Mana Trackers,
# ActiveManaTracker and ActiveColourTracker

class_name ManaValueTracker
extends TextureProgressBar

@onready var visual_bar: ManaValueTracker = $"." 
@export var colour:SpellcraftManager.MANA_COLOURS 
@export var maximum_mana:float
@export var current_mana:float ## Clamped between 0 and maximum_mana. Used as TextureProgressBar value parameter
@export var mana_regen_rate:float ## in Mana per Second

func _ready():
	update_current_mana(maximum_mana)

# Mana Regen done on the mana tracker level.
func _process(delta: float) -> void:
	if(current_mana < maximum_mana):
		update_current_mana(mana_regen_rate * delta)

## Directly changes the value of maximum_mana, then updates current_mana to ensure the same percentage
func set_maximum_mana(new_max:float) -> void:
	var relative_diff = (new_max - maximum_mana)/maximum_mana
	maximum_mana = new_max
	
	# Need to make sure these changes are represented in the Progress Bar values as well
	visual_bar.min_value = 0
	visual_bar.max_value = maximum_mana
	
	# maintain percentage of current/maximum through this update
	update_current_mana(current_mana*relative_diff)

func update_current_mana(mana_change:float)->void:
	current_mana += mana_change
	
	if(current_mana > maximum_mana):
		current_mana = maximum_mana
	elif(current_mana < 0):
		current_mana = 0
		
	update_visuals()

func update_visuals()->void:
	visual_bar.value = current_mana
