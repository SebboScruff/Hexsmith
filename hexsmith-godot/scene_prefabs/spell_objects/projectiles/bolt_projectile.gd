# Behavioural outline for the Bolt Suffix's spawned projectile:
# - Travel in a straight line until hitting an enemy or wall
# - Deal damage if necessary, then destroy itself

extends SpellProjectile

var fire_entity: FireSystemEntity

func _ready() -> void:
	pass # Replace with function body.

# Make the project look the correct way
func initialise_shader(_colors:Array[Color]) -> void:
	# Takes in the Color Array from the Prefix:
	# 0, 1, 2 are Primary, Secondary, Tertiary respectively.
	# 3, 4 are Effect Colors.
	mat.set_shader_parameter("PrimaryColor", _colors[0])
	mat.set_shader_parameter("SecondaryColor", _colors[1])
	mat.set_shader_parameter("TertiaryColor", _colors[2])
	
	var trail := $Trail
	trail.default_color = _colors[3] # For now, set the trail as the Primary Effect color

# Add specific effects from Prefix Color Combos.
func initialise_prefix_effects(_red:int, _blue:int, _green:int, 
_white:int, _black:int, _colorless:int, ) -> void:
	# Add Damage Values based on Colour.
	damage_dict[CombatEntity.DAMAGE_TYPES.RED] = damage_per_mana*_red
	damage_dict[CombatEntity.DAMAGE_TYPES.BLUE] = damage_per_mana*_blue
	damage_dict[CombatEntity.DAMAGE_TYPES.GREEN] = damage_per_mana*_green
	damage_dict[CombatEntity.DAMAGE_TYPES.WHITE] = damage_per_mana*_white
	damage_dict[CombatEntity.DAMAGE_TYPES.BLACK] = damage_per_mana*_black
	
	# Then add specific, colour-based effects.
	fire_entity = $FireSystemEntity
	fire_entity.disable_entity()
	# TODO Refactor this so it isnt terrible
	# Not that there's anything intrinsically wrong with if-chains
	if(_red > 0):
		# Make the bolt an igniter - TODO Requires Fire Management system
		fire_entity.is_igniter = true
		fire_entity.enable_entity()
	elif(_blue > 0):
		# Make the bolt an extinguisher - TODO Requires Fire Management system
		fire_entity.is_extinguisher = true
		fire_entity.enable_entity()
	elif(_green > 0):
		# Make the bolt flammable - TODO Requires Fire Management system
		fire_entity.is_flammable = true
		fire_entity.enable_entity()
	elif(_white > 0):
		# Create a small light and instantiate as child to the projectile
		# TODO Also apply this to the bolt's trail, or otherwise have it linger for a while.
		var light := preload("res://scene_prefabs/circle_light.tscn")
		add_child(light.instantiate())
	elif(_black > 0):
		# Adjust the bolt's collision mask so it doesnt hit terrain (Layer 2)
		set_collision_mask_value(2, false)

func _physics_process(delta: float) -> void:
	# Do movement via SpellProjectile base class's physics process.
	super._physics_process(delta)

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
				#print("Hit %s for %f damage of type %s"%[body.name, damage_dict[t], CombatEntity.DAMAGE_TYPES.keys()[t]])
	# Destroy this bolt
	queue_free()
