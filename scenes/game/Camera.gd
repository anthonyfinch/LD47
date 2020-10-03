extends Camera


export var camera_speed := 1.0


func _ready():
	pass


func _process(delta):
	var offset = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		offset.x = camera_speed
	if Input.is_action_pressed("ui_left"):
		offset.x = -1 * camera_speed
	if Input.is_action_pressed("ui_up"):
		offset.y += camera_speed
	if Input.is_action_pressed("ui_down"):
		offset.y += -1 * camera_speed

	offset = offset * delta
	h_offset += offset.x
	v_offset += offset.y
