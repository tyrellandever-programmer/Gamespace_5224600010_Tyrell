extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var pull_force: Vector2 = Vector2.ZERO

@export var data: PlayerData
@export var projectile_scene: PackedScene

@onready var hp_bar = $ProgressBar

var can_shoot = true
var shoot_cooldown = 0.3
var melee_range = 60


func _ready():
	add_to_group("player")

	if data == null:
		push_warning("DATA BELUM DIISI!")
		return

	update_hp_bar()


func _physics_process(delta):

	if data == null:
		return

	# GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta

	# JUMP
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# MOVE
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# PULL FORCE
	velocity += pull_force * delta
	pull_force = Vector2.ZERO

	move_and_slide()


func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()


func shoot():
	if not can_shoot:
		return

	can_shoot = false

	# ===== RANGED ATTACK (PROJECTILE) =====
	if projectile_scene != null:
		var p = projectile_scene.instantiate()

		var dir = (get_global_mouse_position() - global_position).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT

		p.global_position = global_position + dir * 30
		p.direction = dir
		p.shooter = self

		get_tree().current_scene.add_child(p)

	# ===== MELEE ATTACK (JARAK DEKAT) =====
	for body in get_tree().get_nodes_in_group("enemy"):
		if body == null:
			continue

		if global_position.distance_to(body.global_position) <= melee_range:
			if body.has_method("take_damage"):
				body.take_damage(data.damage)

	# cooldown
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


func take_damage(amount):
	if data == null:
		return

	data.hp = max(data.hp - amount, 0)
	update_hp_bar()

	print("💔 Player kena:", amount, "HP:", data.hp)

	# knockback
	velocity += Vector2(-150, -100)

	if data.hp <= 0:
		die()


func heal(amount):
	if data == null:
		return

	data.hp = min(data.hp + amount, data.max_hp)
	update_hp_bar()


func update_hp_bar():
	if hp_bar:
		hp_bar.value = data.hp


func die():
	print("☠ PLAYER DEAD")
	queue_free()
