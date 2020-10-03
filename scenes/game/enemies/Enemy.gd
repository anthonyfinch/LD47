extends Spatial


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))


func move_by(offset):
	transform.origin.x += offset.x
	transform.origin.z += offset.y
