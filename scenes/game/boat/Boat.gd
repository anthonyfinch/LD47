extends Spatial



export (NodePath) var tween_path := "Tween"
onready var _tween := get_node(tween_path)

export (int) var capacity := 2
export (int) var move_speed := 3

onready var static1 = get_node("MeshInstance/StaticBody")
onready var static2 = get_node("MeshInstance2/StaticBody")

var on_board := 0


func _ready():
	_tween.connect("tween_all_completed", self, "_movement_complete")
	static1.connect("input_event", self, "_on_input_event")
	static2.connect("input_event", self, "_on_input_event")


func _movement_complete():
	# _anim.stop()
	Events.emit_signal("boat_finished_movement")


func _on_input_event(camera, event, click_pos, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			Events.emit_signal("boat_clicked", self)


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))


func move_by(offset):
	var from = transform.origin
	var to = from + Vector3(offset.x, 0, offset.y)
	_tween.interpolate_property(self, "transform:origin",
								from, to,
								1, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	_tween.start()


func is_full():
	if on_board == capacity:
		return true
	return false


func embark():
	on_board += 1
