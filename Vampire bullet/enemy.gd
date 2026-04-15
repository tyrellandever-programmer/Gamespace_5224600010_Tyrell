extends CharacterBody2D

@export var speed = 120
@export var damage = 10
@export var max_hp = 50

@export var attack_range = 45
@export var attack_cooldown = 1.0

var hp
var player = null
var can_attack = true

@onready var hp_bar = $ProgressBar


func _ready():
	hp = max_hp
	
	add_to_group("enemy")
	
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("❌ PLAYER TIDAK DITEMUKAN")


func _physics_process(delta):
	if player == null:
		return

	# CHASE
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	# ATTACK CHECK
	var dist = global_position.distance_to(player.global_position)

	if dist <= attack_range and can_attack:
		attack()


func attack():
	can_attack = false

	print("💥 Enemy ATTACK!")

	if player.has_method("take_damage"):
		player.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func take_damage(amount):
	hp -= amount
	hp = max(hp, 0)

	if hp_bar:
		hp_bar.value = hp

	print("🩸 Enemy kena:", amount, "HP:", hp)

	# knockback enemy
	velocity += Vector2(100, -50)

	if hp <= 0:
		die()


func die():
	print("☠ Enemy Dead")
	queue_free()
