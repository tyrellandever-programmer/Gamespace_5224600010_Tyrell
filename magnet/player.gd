extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var pull_force: Vector2 = Vector2.ZERO

@export var data: PlayerData
@export var projectile_scene: PackedScene

@onready var hp_bar = $ProgressBar

var can_shoot = true
var shoot_cooldown = 0.3


func _ready():
	if data == null:
		print("DATA BELUM DIISI!")
	else:
		hp_bar.max_value = data.max_hp
		hp_bar.value = data.hp


func _physics_process(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	velocity += pull_force * delta
	move_and_slide()

	pull_force = Vector2.ZERO


func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()


func shoot():
	if not can_shoot:
		return

	if projectile_scene == null:
		print("Projectile belum di-assign!")
		return

	can_shoot = false

	var p = projectile_scene.instantiate()

	# arah ke mouse
	var dir = (get_global_mouse_position() - global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT

	# 🔥 spawn di depan player (biar tidak kena diri sendiri)
	p.global_position = global_position + dir * 30

	p.direction = dir
	p.shooter = self

	get_tree().current_scene.add_child(p)

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


func take_damage(amount):
	if data == null:
		return

	data.hp -= amount
	data.hp = max(data.hp, 0)
	update_hp_bar()

	if data.hp <= 0:
		die()


func heal(amount):
	if data == null:
		return

	data.hp += amount
	data.hp = min(data.hp, data.max_hp)
	update_hp_bar()


func update_hp_bar():
	if hp_bar:
		hp_bar.value = data.hp


func die():
	queue_free()
