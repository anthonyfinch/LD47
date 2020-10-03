extends StaticBody


func _ready():
	connect("input_event", self, "_on_input_event")


func _on_input_event(camera, event, click_pos, click_normal, boo):
	var grid_pos = Vector2(floor(click_pos.x), floor(click_pos.z))
	if event is InputEventMouseButton:
		if event.pressed:
			Events.emit_signal("grid_clicked", grid_pos)
	else:
		Events.emit_signal("grid_position", grid_pos)
