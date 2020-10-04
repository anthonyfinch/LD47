extends Spatial


export (NodePath) var tween_path := "Tween"
onready var _tween := get_node(tween_path)
export (NodePath) var anim_path := "AnimationPlayer"
onready var _anim := get_node(anim_path)



func _ready():
	_tween.connect("tween_all_completed", self, "_movement_complete")


func activate():
	_anim.play("bob")


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))


func move_to(pos):
	var target_x = pos.x + 0.5
	var target_z = pos.y + 0.5
	var constant_y = transform.origin.y
	_tween.interpolate_property(self, "transform:origin",
							   transform.origin,
							   Vector3(target_x, constant_y, target_z),
							   1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()


func _movement_complete():
	_anim.stop()
	Events.emit_signal("person_finished_movement")


func can_move_to(pos):
	var my_pos = Vector2(floor(transform.origin.x), floor(transform.origin.z))
	var vec = pos - my_pos
	if abs(floor(vec.x)) > 1 or abs(floor(vec.y)) > 1:
		return false
	return true
