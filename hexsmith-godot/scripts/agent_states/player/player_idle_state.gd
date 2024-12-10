class_name PlayerIdleState
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "Idle"
	self.state_id = 0
	self.player = _player

func on_state_enter() -> void:
	print("Player entered IDLE State")
	player.hud_manager.change_active_menu(0)
	Engine.time_scale = 1.0
	#pass

func on_state_process() -> void:
	pass

func on_state_physics_process() -> void:
	pass

func on_state_exit() -> void:
	print("Player exited IDLE State")
	# pass
