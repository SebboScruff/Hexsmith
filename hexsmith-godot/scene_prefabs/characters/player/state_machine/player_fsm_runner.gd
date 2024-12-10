## Very specific for the player, and does not have an abstract "FSM Runner" Base Class
## because I can't see myself using FSMs for any enemies: it's less suitable than Behaviour Trees
## for major bosses, and needlessly complex for basic enemies.
class_name PlayerFSMRunner
extends Node

var states = {} #NOTE: String Names as keys, State Classes as values.
@export var initial_state:PlayerState

var current_state:PlayerState
var previous_state:PlayerState

## States must be assigned as child nodes to this object.
func _ready():
	for child in get_children():
		if(child is PlayerState):
			states[child.state_name.to_lower()] = child
			child.player = get_parent() as Player
			child.State_Transition.connect(change_state)
			print("Initialised State: %s"%[child.state_name.to_lower()])
	
	if(initial_state):
		initial_state.on_state_enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if(current_state):
		current_state.on_state_process(delta)
	
func _physics_process(delta: float) -> void:
	if(current_state):
		current_state.on_state_physics_process(delta)

func change_state(_old_state:PlayerState, _new_state_name:String):
	var new_state:PlayerState = states.get(_new_state_name.to_lower())
	
	if(!new_state):
		print("No state with name %s found in States Dictionary!"%[_new_state_name])
		return
	if(_old_state == new_state):
		print("Trying to change to current State!")
		return
	
	if(current_state):
		current_state.on_state_exit()
	
	previous_state = current_state
	current_state = new_state
	current_state.on_state_enter()
