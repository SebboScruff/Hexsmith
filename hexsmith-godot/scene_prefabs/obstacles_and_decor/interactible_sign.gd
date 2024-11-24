extends Node2D

@onready var input_prompt: Control = $input_prompt
var is_interactible:bool = false
@export var display_text:String

func _physics_process(delta: float) -> void:
	if(is_interactible && Input.is_action_just_pressed("overworld_interact")):
		print("TODO Interacted With Sign!")

func _on_activation_region_body_entered(body: Node2D) -> void:
	input_prompt.set_visible(true)
	is_interactible = true
	pass # Replace with function body.

func _on_activation_region_body_exited(body: Node2D) -> void:
	input_prompt.set_visible(false)
	is_interactible = false
	pass # Replace with function body.
