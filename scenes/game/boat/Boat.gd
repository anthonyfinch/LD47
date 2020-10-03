extends Spatial


export (int) var capacity := 2
export (int) var move_speed := 3

var _on_board := 0


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))


func move_by(offset):
	transform.origin.x += offset.x
	transform.origin.z += offset.y


func is_full():
	if _on_board == capacity:
		return true
	return false
