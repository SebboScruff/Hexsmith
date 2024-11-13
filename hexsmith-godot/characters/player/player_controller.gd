extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var body_sprite: AnimatedSprite2D = $BodySprite
@onready var hair_sprite: AnimatedSprite2D = $HairSprite
@onready var shirt_sprite: AnimatedSprite2D = $ShirtSprite
@onready var trouser_sprite: AnimatedSprite2D = $TrouserSprite

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("overworld_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("overworld_move_left", "overworld_move_right")
	
	#Sprite Animation
	if direction < 0:
		body_sprite.flip_h = false
		hair_sprite.flip_h = false
		shirt_sprite.flip_h = false
		trouser_sprite.flip_h = false
	elif direction > 0:
		body_sprite.flip_h = true
		hair_sprite.flip_h = true
		shirt_sprite.flip_h = true
		trouser_sprite.flip_h = true
		
	# Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
