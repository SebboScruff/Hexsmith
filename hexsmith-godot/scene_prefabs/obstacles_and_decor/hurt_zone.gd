# Controller for a Hurt Zone - Any hitbox that can damage the player.
# Has a variety of changeable parameters and can be applied to terrain hazards, enemy projectiles,
# or even enemies themselves.
extends Area2D

## Specific deathtraps that kill the player from any health. 
## Damage Amount is irrelevant if this is on.
@export var instakill: bool = false

## Dealt as a single instance of damage every n seconds. n = damage_interval_timer Wait Time.
## If n is low, this should also be low.
@export var damage_amount:float 

## Automatically assigned to this node's Timer child on _ready(). Available here to allow for
## use in constructor as well as assignment in inspector.
@export var interval:float
@onready var damage_interval_timer: Timer = %damage_interval_timer

## e.g. Lava does Red Damage; Spikes do Physical Damage. Default to HP Removal.
@export var damage_type:CombatEntity.DAMAGE_TYPES

## Some hurt zones (e.g. projectiles) will destroy themselves immediately after
## colliding with the player.
@export var destroy_self_on_hit:bool = false

var can_damage:bool # used to control damage interval timer.

# Constructor so these can be instanced alongside projectiles or summoned enemies.
func _init(_instakill:bool = false, _damage_amount:float = 0, _damage_interval:float = 1,
 _damage_type:CombatEntity.DAMAGE_TYPES = CombatEntity.DAMAGE_TYPES.HP_REMOVAL, _destroy_self:bool = false) -> void:
	self.instakill = _instakill
	self.damage_amount = _damage_amount
	# pass into self-contained value in constructor; then pass to timer in _ready()
	self.interval = _damage_interval
	
	self.damage_type = _damage_type
	self.destroy_self_on_hit = _destroy_self

func _ready() -> void:
	damage_interval_timer.wait_time = self.interval

## NOTE: Collision Mask should be set up in a way that puts this onto the Enemy Layer by default,
## and should collide with Player (1), Terrain (2), and Obstacles (7) by default.
func _on_body_entered(body: Node2D) -> void:
	# Get a Combat Entity for damage calculations.
	# In most cases, this will either be the Player or something they have summoned.
	var hit_combat_entity:CombatEntity = body.get_node_or_null("CombatEntity") as CombatEntity
	
	# Deal damage if possible. Conditions: Damage Interval Timer has ended, and Combat Entity
	# was successfully obtained.
	if(can_damage && hit_combat_entity != null):
		can_damage = false
		damage_interval_timer.start()
		
		# Either instantly kill the Combat Entity that was hit (for death pits or unfair enemies)
		# or otherwise deal the normal amount of damage.
		if(instakill):
			hit_combat_entity.take_damage(hit_combat_entity.curr_health, CombatEntity.DAMAGE_TYPES.HP_REMOVAL)
		else:
			hit_combat_entity.take_damage(damage_amount, damage_type)
	
	# This happens outside of Combat Entity detection so that if e.g. a projectile
	# hits a wall, it will still be destroyed.
	if(destroy_self_on_hit):
		queue_free()

func _on_damage_interval_timer_timeout() -> void:
	can_damage = true
	# Quick single-frame toggle to reset the hit detection.
	# Little hack for allowing continuous collision detection
	monitoring = false
	monitoring = true
