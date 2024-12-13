## Very specific for the player, and does not have an abstract "FSM Runner" Base Class
## because I can't see myself using FSMs for any enemies: it's less suitable than Behaviour Trees
## for major bosses, and needlessly complex for basic enemies.
class_name PlayerFSMRunner
extends Node

@onready var debug_current_state: Label = $"../DebugCurrentState"
@onready var debug_previous_state: Label = $"../DebugPreviousState"

var states = {} #NOTE: String Names as keys, State Classes as values.

# Track current state to determine runtime behaviours
var current_state:PlayerState = null
# Track previous state so that the runner doesn't necessarily have to default to Idle
# e.g. after unpausing, we can return to whichever state the player was already in before pausing
var previous_state:PlayerState = null

## PlayerStates must be assigned as child nodes to this object.
func _ready():
	for child in get_children():
		if(child is PlayerState):
			states[child.state_name.to_lower()] = child
			child.player = get_parent() as Player 
			child.hud_manager = child.player.hud_manager
			child.State_Transition.connect(change_state)
			print("Initialised State: %s"%[child.state_name.to_lower()])

func _process(delta: float) -> void:
	if(previous_state != null):
		debug_previous_state.text = "Prev State: %s"%[previous_state.state_name]
	if(current_state):
		debug_current_state.text = "Current State: %s"%[current_state.state_name]
		current_state.on_state_process(delta)
	
func _physics_process(delta: float) -> void:
	if(current_state):
		current_state.on_state_physics_process(delta)

func change_state(_old_state:PlayerState, _new_state_name:String):
	if(!states.keys().has(_new_state_name)):
		print("No state with name %s found in States Dictionary!"%[_new_state_name])
		return
	
	var new_state:PlayerState = states.get(_new_state_name.to_lower())
	
	if(_old_state == new_state):
		print("Trying to change to current State!")
		return
	
	if(current_state):
		current_state.on_state_exit()
	
	previous_state = current_state
	current_state = new_state
	current_state.on_state_enter()

func reset_to_idle():
	print("Reset To Idle called!")
	change_state(current_state, "idle")

func reset_to_previous_state():
	if(previous_state == null):
		print("Tried going to previous state but it is null!")
		return
	
	change_state(current_state, previous_state.state_name.to_lower())
