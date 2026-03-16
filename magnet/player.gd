extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var pull_force: Vector2 = Vector2.ZERO   # gaya tarik dari Area2D

func _physics_process(delta: float) -> void:
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement kiri kanan
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Tambahkan gaya tarik
	velocity += pull_force * delta

	move_and_slide()

	# reset gaya tarik setiap frame
	pull_force = Vector2.ZERO
