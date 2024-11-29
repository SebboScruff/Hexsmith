class_name FireSystemEntity
extends Area2D

#region Control Bools
@export var is_igniter:bool # Igniters will set any Flammable object to On Fire
@export var is_flammable:bool # Flammable Objects are recognised by Igniters
@export var is_extinguisher:bool # Extinguishers will set 
@export var is_extinguishable:bool # Some fires cannot be put out

@export var is_on_fire:bool # Activates visuals, damage instances, etc.
#endregion

#region Fire Damage
var attached_combat_entity:CombatEntity
@onready var fire_damage_interval: Timer = $FireDamageInterval
@onready var fire_damage := 20.0 ## Dealt every time the Interval Timer expires
const FIRE_DAMAGE_TYPE := CombatEntity.DAMAGE_TYPES.RED
#endregion

#region Visuals
# Add some child object particle systems for fire/smoke/steam
# Also add a PointLight2D that gets toggled on/off if it's on fire.
#endregion 

#region Debug
@export var show_debug := true
@onready var debug_readout: PanelContainer = %DebugReadout
@onready var debug_ignite: Label = $DebugReadout/VBoxContainer/DebugIgnite
@onready var debug_extinguish: Label = $DebugReadout/VBoxContainer/DebugExtinguish
@onready var debug_flammable: Label = $DebugReadout/VBoxContainer/DebugFlammable
@onready var debug_on_fire: Label = $DebugReadout/VBoxContainer/DebugOnFire
@onready var debug_extinguishable: Label = $DebugReadout/VBoxContainer/DebugExtinguishable
#endregion

# NOTE: Fire Entities must be set as siblings to Combat Entities in order for Fire Damage
# to be managed correctly.
func _ready() -> void:
	attached_combat_entity = get_parent().get_node_or_null("CombatEntity")
	debug_readout.set_visible(show_debug)

func _process(delta: float) -> void:
	if(show_debug):
		debug_ignite.text = "Ignite: " + var_to_str(is_igniter)
		debug_extinguish.text = "Extinguish: " + var_to_str(is_extinguisher)
		debug_flammable.text = "Flammable: " + var_to_str(is_flammable)
		debug_on_fire.text = "On Fire: " + var_to_str(is_on_fire)
		debug_extinguishable.text = "Extinguishable: " + var_to_str(is_extinguishable)

func enable_entity() -> void:
	set_process(true)
	set_physics_process(true)
	set_visible(true)

func disable_entity() -> void:
	set_process(false)
	set_physics_process(false)
	set_visible(false)

func try_ignite_self() -> void:
	if(is_flammable && !is_on_fire):
		print("%s just got set ablaze"%[get_parent().name])
		is_on_fire = true
		# TODO Enable Fire Particles
		# TODO Play Ignition Sound
		# TODO Enable Point Light
		fire_damage_interval.set_paused(false)
	
func try_extinguish_self() -> void:
	if(is_on_fire && is_extinguishable):
		print("%s just got extinguished"%[get_parent().name])
		is_on_fire = false
		# TODO Disable Fire Particles
		# TODO Enable Steam Particles
		
		# TODO Play Hissing Extinguish Sound
		
		# TODO Disable Point Light
		fire_damage_interval.set_paused(true)

func do_fire_damage() -> void:
	if(attached_combat_entity != null):
		attached_combat_entity.take_damage(fire_damage, FIRE_DAMAGE_TYPE)

# TODO This could probably be made more efficient
static func do_entity_interaction(entity_1:FireSystemEntity, entity_2:FireSystemEntity):
	print("Doing fire Interaction between %s and %s"%[entity_1.get_parent().name, entity_2.get_parent().name])
	## NOTE: This is called twice per Fire Entity Collision, since both areas overlap 
	## at the same time and therefore call this function, with technically both entities
	## taking turns at being "entity 1" and "entity 2"
	# Ignition
	if(entity_1.is_igniter || entity_1.is_on_fire):
		entity_2.try_ignite_self()
	
	# Extinguishing
	elif(entity_1.is_extinguisher):
		entity_2.try_extinguish_self()

static func create_new_fire_entity(_igniter:bool, _flammable:bool, _extinguisher:bool) -> FireSystemEntity:
	var scn = preload("res://scene_prefabs/characters/fire_system_entity.tscn")
	var new_entity = scn.instantiate()
	
	new_entity.is_igniter = _igniter
	new_entity.is_flammable = _flammable
	new_entity.is_extinguisher = _extinguisher
	
	return new_entity


func _on_fire_damage_interval_timeout() -> void:
	do_fire_damage()


func _on_area_entered(area: Area2D) -> void:
	if(area == self):
		return
	var fse := area as FireSystemEntity
	if(fse == null):
		return
	## Getting to this point means this Fire Entity has overlapped with another
	do_entity_interaction(self, fse)
