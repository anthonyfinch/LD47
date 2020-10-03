extends Spatial


func move_by(offset):
	transform.origin.x += offset.x
	transform.origin.z += offset.y
