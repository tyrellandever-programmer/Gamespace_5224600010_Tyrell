extends CharacterBody2D

@export var speed = 100
@export var damage = 8
@export var max_hp = 50

@export var attack_range = 45
@export var attack_cooldown = 1.0
@export var detection_range = 200

@export var gravity = 800
@export var idle_time = 2.0

@export var patrol_points: Array[Node2D]

enum {
	IDLE,
	PATROL,
	CHASE
}

var state = IDLE
var patrol_index = 0
var idle_timer = 0.0

var hp
var player = null
var can_attack = true

@onready var hp_bar = $ProgressBar
@onready var nav_agent = $NavigationAgent2D


func _ready():
	hp = max_hp
	idle_timer = idle_time
	
	add_to_group("enemy")

	# HP bar
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp

	# cari player
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("❌ PLAYER TIDAK DITEMUKAN")

	# navigation setting
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 8.0


func _physics_process(delta):
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)

	update_state(dist)

	match state:
		IDLE:
			idle(delta)
		PATROL:
			patrol(delta)
		CHASE:
			chase(delta)

	move_and_slide()

	# attack
	if dist <= attack_range and can_attack:
		attack()


# ========================
# STATE LOGIC
# ========================
func update_state(dist):
	if dist <= detection_range:
		state = CHASE
	elif state == CHASE:
		state = PATROL


# ========================
# IDLE
# ========================
func idle(delta):
	velocity.x = 0

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	idle_timer -= delta

	if idle_timer <= 0:
		state = PATROL
		idle_timer = idle_time


# ========================
# PATROL (FIXED)
# ========================
func patrol(delta):
	if patrol_points.is_empty():
		print("❌ Patrol kosong!")
		return

	var target = patrol_points[patrol_index].global_position
	nav_agent.target_position = target

	if nav_agent.is_navigation_finished():
		return

	var next_pos = nav_agent.get_next_path_position()

	if global_position.distance_to(next_pos) < 2:
		return

	var dir = (next_pos - global_position).normalized()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	velocity.x = dir.x * speed

	# sampai titik
	if global_position.distance_to(target) < 10:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		state = IDLE
		idle_timer = idle_time


# ========================
# CHASE
# ========================
func chase(delta):
	nav_agent.target_position = player.global_position

	if nav_agent.is_navigation_finished():
		return

	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	velocity.x = dir.x * speed


# ========================
# ATTACK
# ========================
func attack():
	can_attack = false

	if player.has_method("take_damage"):
		player.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# ========================
# DAMAGE
# ========================
func take_damage(amount):
	hp -= amount
	hp = max(hp, 0)

	if hp_bar:
		hp_bar.value = hp

	velocity += Vector2(100, -150)

	if hp <= 0:
		die()


func die():
	queue_free()
