extends StaticBody


func _ready():
	connect("input_event", self, "_on_input_event")


func _on_input_event(camera, event, click_pos, click_normal, boo):
	print(camera, event, click_pos, click_normal, boo)
