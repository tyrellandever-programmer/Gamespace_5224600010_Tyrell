extends Area2D

@export var speed = 600
@export var lifetime = 2.0

var direction = Vector2.ZERO
var shooter = null


func _ready():
	# auto delete biar tidak numpuk
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):

	# ❗ jangan kena diri sendiri
	if body == shooter:
		return

	# ❗ safety check
	if shooter == null:
		return

	# ===== DAMAGE SYSTEM =====
	if body.has_method("take_damage"):

		# damage dari shooter
		var damage = 10
		if shooter.data != null:
			damage = shooter.data.damage

		body.take_damage(damage)

		# ===== LIFESTEAL =====
		if shooter.has_method("heal") and shooter.data != null:
			var heal_amount = damage * shooter.data.lifesteal
			shooter.heal(heal_amount)

	queue_free()
