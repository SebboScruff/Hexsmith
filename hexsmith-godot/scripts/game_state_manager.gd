# Global Game State Manager:
# Used to monitor pause states, save-load system
# story progression and events, etc.
extends Node

@export var current_game_state : States.GAME_STATES

func _init() -> void:
	current_game_state = States.GAME_STATES.OVERWORLD
