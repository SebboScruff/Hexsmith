class_name FireSystemEntity
extends Area2D

#region Control Bools
@export var is_igniter:bool ## Will this entity Set Fire to any Flammable Objects it collides?
@export var is_flammable:bool ## Can this entity be set on fire by Igniters?
@export var is_extinguisher:bool ## Can this entity put out fires?
@export var is_extinguishable := true ## Can this entity be put out if it is on fire?

@export var is_on_fire:bool # Activates visuals, damage instances, etc.
#endregion

#region Fire Damage
var attached_combat_entity:CombatEntity
@onready var fire_damage_interval: Timer = $FireDamageInterval
@onready var fire_damage := 20.0 ## Dealt every time the Interval Timer expires
const FIRE_DAMAGE_TYPE := CombatEntity.DAMAGE_TYPES.RED
#endregion

#region Visuals
@onready var on_fire_particles: GPUParticles2D = $SmokeParticles
@onready var extinguish_particles: GPUParticles2D = $ExtinguishParticles

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
	
	on_fire_particles.set_visible(is_on_fire)
	on_fire_particles.emitting = is_on_fire

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
		# Internal State Management
		is_on_fire = true 
		fire_damage_interval.set_paused(false)
		
		# Visuals
		on_fire_particles.set_visible(true)
		on_fire_particles.emitting = true
		extinguish_particles.set_visible(false)
		extinguish_particles.emitting = false
		# TODO Sound Effects
		# TODO Lighting

func try_extinguish_self() -> void:
	if(is_on_fire && is_extinguishable):
		# Internal State Management
		is_on_fire = false
		fire_damage_interval.set_paused(true)
		
		# Visuals
		on_fire_particles.set_visible(false)
		on_fire_particles.emitting = false
		extinguish_particles.set_visible(true)
		extinguish_particles.emitting = true
		
		# TODO Sound Effects
		# TODO Lighting


func do_fire_damage() -> void:
	if(attached_combat_entity != null):
		attached_combat_entity.take_damage(fire_damage, FIRE_DAMAGE_TYPE)

# TODO This could probably be made more efficient
static func do_entity_interaction(entity_1:FireSystemEntity, entity_2:FireSystemEntity):
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
	monitoring = false
	monitoring = true
