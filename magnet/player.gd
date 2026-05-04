extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var facing = 1

@export var data: PlayerData
@export var projectile_scene: PackedScene

@onready var hp_bar = $ProgressBar
@onready var exp_bar = $ProgressBar2
@onready var level_label = $Label
@onready var level_effect = $LevelUpEffect

var can_shoot = true
var shoot_cooldown = 0.3


func _ready():
	add_to_group("player")
	facing = 1
	update_hp_bar()
	update_level_label()


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	# JUMP
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# MOVE
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# pastikan facing tidak pernah 0
	if facing == 0:
		facing = 1

	move_and_slide()


func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()


# ========================
# SHOOT SYSTEM (AUTO TARGET)
# ========================
func shoot():
	if not can_shoot:
		return

	can_shoot = false

	var target = get_nearest_enemy()
	var dir: Vector2 = Vector2.ZERO

	# PRIORITAS: enemy terdekat
	if target != null:
		dir = (target.global_position - global_position).normalized()

	# FALLBACK: arah karakter
	if dir == Vector2.ZERO:
		dir = Vector2(facing, 0)

	if projectile_scene != null:
		var p = projectile_scene.instantiate()

		p.global_position = global_position + dir * 30
		p.direction = dir.normalized()
		p.shooter = self

		get_tree().current_scene.add_child(p)
	else:
		print("❌ projectile_scene belum diisi!")

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


# ========================
# CARI ENEMY TERDEKAT
# ========================
func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")

	var nearest = null
	var min_dist = INF

	for e in enemies:
		if e == null:
			continue

		var dist = global_position.distance_to(e.global_position)

		if dist < min_dist:
			min_dist = dist
			nearest = e

	return nearest


# ========================
# DAMAGE SYSTEM
# ========================
func take_damage(amount):
	data.hp = max(data.hp - amount, 0)
	update_hp_bar()

	if data.hp <= 0:
		die()


func update_hp_bar():
	if hp_bar:
		hp_bar.value = data.hp


func die():
	queue_free()
	
# ========================
# EXPERIENCE SYSTEM
# ========================

func add_exp(amount):
	data.exp += amount

	while data.exp >= data.max_exp:
		level_up()

	update_exp_bar()
	
func update_exp_bar():
	if exp_bar:
		exp_bar.max_value = data.max_exp
		exp_bar.value = data.exp

func level_up():
	data.level += 1
	data.exp -= data.max_exp
	data.max_exp += 50

	update_level_label()
	play_level_effect()

	print("LEVEL UP! Level sekarang:", data.level)

func update_level_label():
	if level_label:
		level_label.text = "Lv " + str(data.level)

func play_level_effect():
	if level_effect:
		level_effect.global_position = global_position
		level_effect.restart()
