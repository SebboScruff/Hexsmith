extends Node
# Global Game State Manager:
# Used to monitor pause states, save-load system
# story progression and events, etc.

enum PLAY_STATES{OVERWORLD, SPELLCRAFT, PAUSED} 
var current_play_state : PLAY_STATES
