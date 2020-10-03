extends Spatial


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))

func move_to(pos):
	transform.origin.x = pos.x + 0.5
	transform.origin.z = pos.y + 0.5


func can_move_to(pos):
	var my_pos = Vector2(floor(transform.origin.x), floor(transform.origin.z))
	var vec = pos - my_pos
	if abs(floor(vec.x)) > 1 or abs(floor(vec.y)) > 1:
		return false
	return true
