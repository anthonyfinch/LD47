extends Camera


func _ready():
	pass


func _process(delta):
	var offset = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		offset.x = 1
	if Input.is_action_pressed("ui_left"):
		offset.x = -1
	if Input.is_action_pressed("ui_up"):
		offset.y += 1
	if Input.is_action_pressed("ui_down"):
		offset.y += -1

	offset = offset * delta
	h_offset += offset.x
	v_offset += offset.y
