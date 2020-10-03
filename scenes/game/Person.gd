extends Spatial


func move_to(pos):
	transform.origin.x = pos.x + 0.5
	transform.origin.z = pos.y + 0.5
	# transform = transform.translated(Vector3(pos.x + 0.5, 0, pos.y + 0.5))
