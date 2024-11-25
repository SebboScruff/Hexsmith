# TODO This probably wants to turn into a generic, inheritable SpellProjectile
# class - so the majority of the initialisation can be kept consistent.
extends Area2D

@export var travel_speed:float
var visual: Sprite2D

var mat : ShaderMaterial
var base_tex:Texture2D
var colors:Array[Color]

# Set up as a dictionary with float values and damage type keys for easy access
# in both initialisation and damage calc.
var damage_dict = {
	CombatEntity.DAMAGE_TYPES.RED : 0.0,
	CombatEntity.DAMAGE_TYPES.BLUE : 0.0,
	CombatEntity.DAMAGE_TYPES.GREEN : 0.0,
	CombatEntity.DAMAGE_TYPES.WHITE : 0.0,
	CombatEntity.DAMAGE_TYPES.BLACK : 0.0,
}

func _init() -> void:
	mat = material
	mat.resource_local_to_scene = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Make the project look the correct way
func initialise_shader(colors:Array[Color]) -> void:
	# Takes in the Color Array from the Prefix:
	# 0, 1, 2 are Primary, Secondary, Tertiary respectively.
	# 3, 4 are Effect Colors.
	print("Primary Color is: " + var_to_str(colors[0]))
	mat.set_shader_parameter("PrimaryColor", colors[0])

# Add specific effects from Prefix Color Combos.
func initialise_prefix_effects(_red:int, _blue:int, _green:int, 
_white:int, _black:int, _colorless:int, ) -> void:
	# Add Damage Values based on Colour.
	# Then add specific, colour-based effects.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Move Forward based on this objects forward vector.
	var move_dir = Vector2.LEFT.rotated(self.rotation)
	self.position += move_dir * delta * travel_speed

func _on_body_entered(body: Node2D) -> void:
	print("Bolt hit %s"%[body.name])
	# Find combat entity of body (if any)
	# Deal damage based on this bolt's colour input
	# Destroy this bolt
	queue_free()
