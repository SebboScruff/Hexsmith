## The default overworld state. The player starts as Idle, and returns if no other input
## is done.
class_name PlayerSpellcraftState
extends PlayerState

func _init() -> void:
	self.state_name = "Spellcraft"
	self.state_id = 1

func on_state_enter() -> void:
	print("Player entered SPELLCRAFT State")
	player.is_spellcrafting = true
	# Timescale to 0.1
	# Open Spellcraft Menu
	#pass

func on_state_process(delta:float) -> void:
	pass

func on_state_physics_process(delta:float) -> void:
	# Return to Idle if the Spellcraft Menu Button is pressed again
	if(Input.is_action_just_pressed("toggle_spellcraft_menu")):
		State_Transition.emit(self, "idle")
	## SPELLCRAFT CONTROLS HERE
	pass

func on_state_exit() -> void:
	print("Player exited Spellcraft State")
	player.is_spellcrafting = false
	# pass
