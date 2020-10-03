extends Spatial


export (int) var capacity := 2
export (int) var move_speed := 3

onready var static1 = get_node("MeshInstance/StaticBody")
onready var static2 = get_node("MeshInstance2/StaticBody")

var on_board := 0


func _ready():
	static1.connect("input_event", self, "_on_input_event")
	static2.connect("input_event", self, "_on_input_event")


func _on_input_event(camera, event, click_pos, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			Events.emit_signal("boat_clicked", self)


func get_grid_pos():
	return Vector2(floor(transform.origin.x), floor(transform.origin.z))


func move_by(offset):
	transform.origin.x += offset.x
	transform.origin.z += offset.y


func is_full():
	if on_board == capacity:
		return true
	return false


func embark():
	on_board += 1
