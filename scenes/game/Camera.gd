extends Camera

export (NodePath) var tween_path := "Tween"
onready var _tween := get_node(tween_path)

export (NodePath) var area_path := "Area2D"
onready var _area := get_node(area_path)



export var shake_magnitude := 1.0
export var camera_speed := 1.0

export var free_move_speed := 1.0
export var free_move_margin := 0.1

var free_move := false

var _mouse_over := true


func _ready():
	_area.connect("mouse_entered", self, "_on_mouse_enter")
	_area.connect("mouse_exited", self, "_on_mouse_exit")


func _on_mouse_enter():
	_mouse_over = true

func _on_mouse_exit():
	_mouse_over = false


func _shake(_t):
	var offset = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)) * shake_magnitude
	h_offset += offset.x
	v_offset += offset.y


func _process(delta):
	if free_move and _mouse_over:
		var mouse_pos = get_viewport().get_mouse_position()
		var w_size = OS.get_window_size()
		var norm_pos = mouse_pos / w_size
		var offset = Vector2(0, 0)
		# print(norm_pos)

		if norm_pos.x <= free_move_margin:
			offset.x = -1
		elif 1.0 - norm_pos.x <= free_move_margin:
			offset.x = 1

		if norm_pos.y <= free_move_margin:
			offset.y = 1
		elif 1.0 - norm_pos.y <= free_move_margin:
			offset.y = -1

		offset = offset.normalized() * free_move_speed * delta

		h_offset += offset.x
		v_offset += offset.y
	# var offset = Vector2.ZERO

	# if Input.is_action_pressed("ui_accept"):
	# 	_foo()
	# 	# var ray = project_ray_origin(Vector2(512, 300))
	# 	# print(ray)
	# 	# # print(to_global(ray))
	# 	# print(h_offset, " ", v_offset)
	# 	# # print(unproject_position(Vector3(0,0,0)))
	# if Input.is_action_pressed("ui_right"):
	# 	offset.x = camera_speed
	# if Input.is_action_pressed("ui_left"):
	# 	offset.x = -1 * camera_speed
	# if Input.is_action_pressed("ui_up"):
	# 	offset.y += camera_speed
	# if Input.is_action_pressed("ui_down"):
	# 	offset.y += -1 * camera_speed

	# offset = offset * delta
	# h_offset += offset.x
	# v_offset += offset.y


func shake(time, delay):
	_tween.interpolate_method(self, "_shake", 0.0, 1.0, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	if not _tween.is_active():
		_tween.start()


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
