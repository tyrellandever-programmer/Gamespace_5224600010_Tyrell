extends Area2D

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			var direction = (global_position - body.global_position).normalized()
			body.velocity += direction * 10000 * delta
