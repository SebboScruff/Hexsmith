# TODO This probably wants to turn into a generic, inheritable SpellProjectile
# class - so the majority of the initialisation can be kept consistent.
extends Area2D

var visual: Sprite2D

var mat : ShaderMaterial
var base_tex:Texture2D
var colors:Array[Color]

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
@export var damage_per_mana = 10.0

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
	damage_dict[CombatEntity.DAMAGE_TYPES.RED] = damage_per_mana*_red
	damage_dict[CombatEntity.DAMAGE_TYPES.BLUE] = damage_per_mana*_blue
	damage_dict[CombatEntity.DAMAGE_TYPES.GREEN] = damage_per_mana*_green
	damage_dict[CombatEntity.DAMAGE_TYPES.WHITE] = damage_per_mana*_white
	damage_dict[CombatEntity.DAMAGE_TYPES.BLACK] = damage_per_mana*_black
	# Then add specific, colour-based effects.s
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Move Forward based on this objects forward vector.
	var move_dir = Vector2.LEFT.rotated(self.rotation)
	self.position += move_dir * delta * travel_speed

func _on_body_entered(body: Node2D) -> void:
	# Find combat entity of body (if any)
	var hit_combat_entity:CombatEntity = body.get_node_or_null("CombatEntity") as CombatEntity
	
	# This loop will activate if the projectile hits anything other than terrain.
	# Both enemies and destructible obstacles will have CombatEntity attached to them
	if(hit_combat_entity != null):
		# Deal damage based on this bolt's colour input
		# NOTE: damage_dict[t] is the raw outgoing damage value.
		for t in damage_dict.keys():
			if(damage_dict[t] != 0):
				hit_combat_entity.take_damage(damage_dict[t], t)
				print("Hit %s for %f damage of type %s"%[body.name, damage_dict[t], CombatEntity.DAMAGE_TYPES.keys()[t]])
	# Destroy this bolt
	queue_free()
