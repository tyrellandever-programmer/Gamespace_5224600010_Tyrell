extends Area2D

@export var speed = 600
var direction = Vector2.ZERO
var shooter = null

func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):

	# ❗ jangan kena diri sendiri
	if body == shooter:
		return

	# ❗ safety check
	if shooter == null:
		return

	if shooter.data == null:
		return

	if body.has_method("take_damage"):
		body.take_damage(shooter.data.damage)

		var heal_amount = shooter.data.damage * shooter.data.lifesteal
		shooter.heal(heal_amount)

	queue_free()
