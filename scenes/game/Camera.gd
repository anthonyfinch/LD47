extends Camera

export (NodePath) var tween_path := "Tween"
onready var _tween := get_node(tween_path)


export var camera_speed := 1.0


func _foo():
	var ray = project_ray_origin(Vector2(512, 300))
	print(to_local(ray))
	# print(to_global(ray))
	print(h_offset, " ", v_offset)
	h_offset += 1
	v_offset += 1
	ray = project_ray_origin(Vector2(512, 300))
	print(to_local(ray))


func _process(delta):
	var offset = Vector2.ZERO

	if Input.is_action_pressed("ui_accept"):
		_foo()
		# var ray = project_ray_origin(Vector2(512, 300))
		# print(ray)
		# # print(to_global(ray))
		# print(h_offset, " ", v_offset)
		# # print(unproject_position(Vector3(0,0,0)))
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


func move_to(pos, time):
	var w_centre = OS.get_window_size() / 2
	var local_object_pos = to_local(pos)
	var ray = project_ray_origin(w_centre)
	var local_center = to_local(ray)

	var offset = local_center - local_object_pos
	# h_offset -= offset.x
	# v_offset -= offset.y

	_tween.remove_all()
	_tween.interpolate_property(self, "h_offset",
								h_offset, h_offset - offset.x,
								time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	_tween.interpolate_property(self, "v_offset",
								v_offset, v_offset - offset.y,
								time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	_tween.start()
