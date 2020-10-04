extends Spatial


export (NodePath) var tween_path := "Tween"
onready var _tween := get_node(tween_path)


func _ready():
	_tween.connect("tween_all_completed", self, "_movement_complete")


func _movement_complete():
	# _anim.stop()
	Events.emit_signal("enemy_finished_movement")


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))


func move_by(offset, delay):
	# transform.origin.x += offset.x
	# transform.origin.z += offset.y
	var from = transform.origin
	var to = from + Vector3(offset.x, 0, offset.y)
	_tween.interpolate_property(self, "transform:origin",
								from, to,
								1, Tween.TRANS_EXPO, Tween.EASE_OUT, delay)
	_tween.start()
