# Global Game State Manager:
# Used to monitor pause states, save-load system
# story progression and events, etc.
extends Node

@export var current_game_state : States.GAME_STATES

func _init() -> void:
	current_game_state = States.GAME_STATES.OVERWORLD

func change_game_state(new_state:States.GAME_STATES):
	current_game_state = new_state
	# print("Changed to new Game State: " + States.GAME_STATES.keys()[new_state])
	# change things based on new game state e.g. timescale
	match(current_game_state):
		States.GAME_STATES.OVERWORLD:
			Engine.time_scale = 1.0
		States.GAME_STATES.CUTSCENE:
			Engine.time_scale = 1.0
		States.GAME_STATES.SPELLCRAFTING:
			Engine.time_scale = 0.1
		States.GAME_STATES.PAUSED:
			Engine.time_scale = 0.0
