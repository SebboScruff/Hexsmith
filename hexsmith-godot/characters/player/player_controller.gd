extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var body_sprite: AnimatedSprite2D = $BodySprite

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("overworld_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("overworld_move_left", "overworld_move_right")
	
	#Sprite Animation:
	# Flip depending on Movement Direction
	if direction > 0:
		body_sprite.flip_h = false
	elif direction < 0:
		body_sprite.flip_h = true
		
	#Then determine animations
	if is_on_floor():
		if direction == 0:
			body_sprite.play("idle")
		else:
			body_sprite.play("run")
	else:
		body_sprite.play("jump_whole")
		
	# Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
