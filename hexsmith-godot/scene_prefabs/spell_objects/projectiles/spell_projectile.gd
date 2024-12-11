# Generic base class for every spell projectile - for example, Bolt and Spear suffixes.
# Handles Shader/ Material initialisation, movement, and basic damage values,
# and provides inheritable methods for initialising specific prefix effects.

class_name SpellProjectile
extends Area2D

#region Visuals
var visual: Sprite2D

var mat : ShaderMaterial
var base_tex:Texture2D
var colors:Array[Color]
#endregion

## How fast does this projectile travel in pixels/s
## Needs to be somewhere in the region of 200-500 to have any reasonable speed.
@export var travel_speed:float

# Set up as a dictionary with float values and damage type keys for easy access
# in both initialisation and damage calc.
var damage_dict = {
	CombatEntity.DAMAGE_TYPES.RED : 0.0,
	CombatEntity.DAMAGE_TYPES.BLUE : 0.0,
	CombatEntity.DAMAGE_TYPES.GREEN : 0.0,
	CombatEntity.DAMAGE_TYPES.WHITE : 0.0,
	CombatEntity.DAMAGE_TYPES.BLACK : 0.0,
}
## The amount of damage dealt by a single instance of mana in this spell.
## e.g. if the spell contains 2 Red Mana, it will deal 2 * [this value] as RED damage.
@export var damage_per_mana:float

# This material initialisation must be consistent across all spell projectiles
func _init() -> void:
	mat = material
	mat.resource_local_to_scene = true

func _ready() -> void:
	print("NOTE: Calling _ready() from default Spell Projectile class.")
	pass # Replace with function body.

# Make the project look the correct way
func initialise_shader(_colors:Array[Color]) -> void:
	# Takes in the Color Array from the Prefix:
	# 0, 1, 2 are Primary, Secondary, Tertiary respectively.
	mat.set_shader_parameter("PrimaryColor", _colors[0])
	mat.set_shader_parameter("SecondaryColor", _colors[1])
	mat.set_shader_parameter("TertiaryColor", _colors[2])
	# 3, 4 are Effect Colors.
	mat.set_shader_parameter("EffectColor1", _colors[3])
	mat.set_shader_parameter("EffectColor2", _colors[4])

# Add specific effects from Prefix Color Combos.
func initialise_prefix_effects(_red:int, _blue:int, _green:int, 
_white:int, _black:int, _colorless:int, ) -> void:
	print("NOTE: Calling initialise_prefix_effects from base SpellProjectile class.")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Move Forward based on this objects forward vector.
	var move_dir = Vector2.LEFT.rotated(self.rotation)
	self.position += move_dir * delta * travel_speed

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node2D) -> void:
	print("NOTE: Calling Base SpellProjectile class on_body_entered(). Destroying this projectile.")
	queue_free()
