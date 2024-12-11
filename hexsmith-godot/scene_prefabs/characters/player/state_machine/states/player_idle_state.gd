## The default overworld state. The player starts as Idle, and returns if no other input
## is done.
class_name PlayerIdleState
extends PlayerState

func _init() -> void:
	self.state_name = "Idle"
	self.state_id = 0

func on_state_enter() -> void:
	print("Player entered IDLE State")
	player.can_cast = true
	player.gravity_scale = 1.0
	# Set Engine Timescale to 1.0
	Engine.time_scale = 1.0
	# Activate Overworld HUD
	hud_manager.change_active_menu(hud_manager.overworld_hud)
	# Play Idle Animation
	player.body_sprite.play("idle")
	#pass

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
	# Idle is the base overworld state, and need a big transition tree based on input:
	# Walking or Running
	if(Input.get_axis("overworld_move_left", "overworld_move_right") != 0):
		if(Input.is_action_pressed("overworld_toggle_sprint")):
			State_Transition.emit(self, "run")
		else:
			State_Transition.emit(self, "walk")
	# Crouching/ crawling
	elif(player.is_on_floor() && Input.is_action_just_pressed("overworld_down")):
		State_Transition.emit(self, "crawl")
	# Jumping
	elif(Input.is_action_pressed("overworld_jump")):
		if(player.is_on_floor() || player.can_surface):
			State_Transition.emit(self, "jump")
	# Falling
	# Climbing
	# Swimming
	# Basic Melee Attack
	elif(player.is_melee_ready && Input.is_action_just_pressed("overworld_melee_attack")):
		State_Transition.emit(self, "basic melee")
	# Pre-casting a Spell
	elif(player.can_cast):
		# TODO These want to eventually be spell-index-specific,
		# so if you are precasting Spell Slot 1, you can ONLY cast Spell Slot 1
		if(Input.is_action_just_pressed("overworld_cast_spellslot1")):
			State_Transition.emit(self, "precast")
		elif(Input.is_action_just_pressed("overworld_cast_spellslot2")):
			State_Transition.emit(self, "precast")
		elif(Input.is_action_just_pressed("overworld_cast_spellslot3")):
			State_Transition.emit(self, "precast")
		elif(Input.is_action_just_pressed("overworld_cast_spellslot4")):
			State_Transition.emit(self, "precast")
	# Pressing and Holding a Spell
	

func on_state_exit() -> void:
	print("Player exited IDLE State")
	# pass
