class_name GameStates

enum GAME_STATES{
	LOADING,		# Before the game has started. This is questionably necessary
	OVERWORLD,		# The vast majority of the game is played in this state. Controls as normal.
	SPELLCRAFTING,	# While the player is in the Spellcraft Menu
	PAUSED,			# While the player is in the Pause Menu
	CUTSCENE		# If the player is in the game but unable to use controls. E.g. reading a sign, talking to NPC, etc.
}
