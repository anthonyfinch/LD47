extends Spatial


export (PackedScene) var next_level = null
export (NodePath) var overlay_path := "Overlay"
export (NodePath) var camera_path := "Camera"
export (NodePath) var tile_tween_path := "TileTween"
export (NodePath) var tile_holder_path := "TileHolder"
export (NodePath) var people_path := "People"
export (NodePath) var enemies_path := "Enemies"
export (NodePath) var boats_path := "Boats"
export (NodePath) var boat_point_path := "BoatPoint"
export (NodePath) var grid_path := "GridMap"
export (PackedScene) var boat_scene = null
export (PackedScene) var lowest_tile = null
export (PackedScene) var medium_tile = null
export (int) var max_moves := 3
export (int) var lowest_tile_index := 1
export (int) var medium_tile_index := 2
export (int) var turns_till_boat := 3

onready var _overlay := get_node(overlay_path)
onready var _camera := get_node(camera_path)
onready var _tile_tween := get_node(tile_tween_path)
onready var _tile_holder := get_node(tile_holder_path)
onready var _people := get_node(people_path)
onready var _enemies := get_node(enemies_path)
onready var _grid := get_node(grid_path)
onready var _boats := get_node(boats_path)
onready var _boat_point := get_node(boat_point_path)

var _dropping_tile: MeshInstance = null
var _selected_person: Spatial = null
var _state = GameStates.AWAITING_INPUT
var _moves_done := 0
var _turn := 1
var _total_people := 0
var _rescued_people := 0
var _enemies_queue := []



enum GameStates {
	AWAITING_INPUT,
	MOVING_PERSON,
	DROPPING_TILE,
	ENEMIES_TURN,
	BOAT_MOVING,
	LEVEL_OVER
}


# Handlers

func _ready():
	Events.connect("grid_clicked", self, "_on_grid_clicked")
	Events.connect("grid_position", self, "_on_grid_position")
	Events.connect("boat_clicked", self, "_on_boat_clicked")

	Events.connect("person_finished_movement", self, "_end_person_movement")
	Events.connect("enemy_finished_movement", self, "_end_enemy_turn")
	Events.connect("boat_finished_movement", self, "_end_boat_turn")
	Events.connect("end_level_button_pressed", self, "_end_level")

	_tile_tween.connect("tween_all_completed", self, "_end_tile_drop")

	_set_rescue_total(0)
	_set_people_total(_people.get_children().size())
	_set_state(GameStates.AWAITING_INPUT)

	_camera.free_move = true


func _set_state(state):
	_state = state
	_signal_state_change()


func _set_moves(moves):
	_moves_done = moves
	_signal_state_change()


func _set_rescue_total(count):
	_rescued_people = count
	Events.emit_signal("rescue_total_set", _rescued_people)


func _set_people_total(count):
	_total_people = count
	Events.emit_signal("people_total_set", _total_people)


func _signal_state_change():
	var msg = ""
	match _state:
		GameStates.AWAITING_INPUT:
			msg = "Player Turn\n%s Moves Remaining" % (max_moves - _moves_done)
		GameStates.MOVING_PERSON:
			msg = "Player Turn\n%s Moves Remaining" % (max_moves - _moves_done)
		GameStates.DROPPING_TILE:
			msg = "Landscape Turn"
		GameStates.ENEMIES_TURN:
			msg = "Enemies Turn"
		GameStates.BOAT_MOVING:
			msg = "Ship Turn"
		GameStates.LEVEL_OVER:
			msg = "Level Over"

	Events.emit_signal("state_set", msg)


func _end_level():
	var _total_rescue = _rescued_people
	for boat in _boats.get_children():
		_total_rescue += boat.on_board

	if _total_rescue == _total_people:
		SceneSwitcher.goto_scene(next_level)
	else:
		get_tree().reload_current_scene()


func _end_tile_drop():
	if _state == GameStates.DROPPING_TILE:
		_dropping_tile.queue_free()
		_start_enemy_turn()


func _end_enemy_turn():
	_do_enemy_move()


func _end_boat_turn():
	_state = GameStates.AWAITING_INPUT
	_camera.free_move = true
	_turn += 1


func _end_person_movement():
	if _state == GameStates.MOVING_PERSON:
		_set_moves(_moves_done + 1)
		_end_player_move()


func _on_grid_clicked(pos):
	if _state == GameStates.AWAITING_INPUT:
		_do_move(pos)


func _on_grid_position(pos):
	pass


func _on_boat_clicked(boat):
	if _state == GameStates.AWAITING_INPUT:
		if _selected_person != null and not boat.is_full():
			var pos = boat.get_grid_pos()
			var positions = [
				Vector2(pos.x, pos.y),
				Vector2(pos.x, pos.y + 1),
				Vector2(pos.x, pos.y + 2)
				]
			var already_found = false
			for boat_pos in positions:
				if not already_found:
					if _selected_person.can_move_to(boat_pos):
						_set_moves(_moves_done + 1)
						_selected_person.queue_free()
						_selected_person = null
						boat.embark()
						already_found = true
						_end_player_move()


# Core

func _do_move(pos):
	if _selected_person == null:
		var clicked = _find_person(pos)
		if clicked != null and _is_floor_tile(pos):
			clicked.activate()
			_selected_person = clicked
	else:
		if _selected_person.can_move_to(pos) and _is_floor_tile(pos) and not pos == _selected_person.get_grid_pos():
				_set_state(GameStates.MOVING_PERSON)
				_selected_person.move_to(pos)
				_selected_person = null

func _end_player_move():
	if _moves_done == max_moves:
		_camera.free_move = false
		_set_moves(0)
		_drop_tile()
	else:
		_set_state(GameStates.AWAITING_INPUT)

	_check_state()


func _drop_tile():
	var used = _grid.get_used_cells()
	var lowest = []
	var medium = []

	for cell in used:
		var tile = _grid.get_cell_item(cell.x, cell.y, cell.z)
		if tile == lowest_tile_index:
			lowest.push_back(cell)
		elif tile == medium_tile_index:
			medium.push_back(cell)

	var to_delete = null
	if lowest.size() > 0:
		to_delete = lowest[randi() % lowest.size()]
	elif medium.size() > 0:
		to_delete = medium[randi() % medium.size()]

	if to_delete != null:
		var tile = _grid.get_cell_item(to_delete.x, to_delete.y, to_delete.z)
		var magic_origin = to_delete + Vector3(0.4, 0.2, 0.4)  # MAGIC
		_camera.move_to(magic_origin, 0.5)
		_camera.shake(0.7, 0.5)
		if tile == lowest_tile_index:
			_dropping_tile = lowest_tile.instance()
		else:
			_dropping_tile = medium_tile.instance()

		# _dropping_tile.transform.origin = to_delete
		# _dropping_tile.transform.origin += Vector3(0.4, 0.2, 0.4)  # MAGIC
		_dropping_tile.transform.origin = magic_origin
		_tile_holder.add_child(_dropping_tile)
		_tile_tween.interpolate_property(_dropping_tile, "transform:origin",
										 _dropping_tile.transform.origin,
										 _dropping_tile.transform.origin - Vector3(0, 10, 0),
										 1, Tween.TRANS_QUINT, Tween.EASE_IN, 0.5)
		var person = _find_person(Vector2(to_delete.x, to_delete.z))
		if person != null:
			person.queue_free()
		_grid.set_cell_item(to_delete.x, to_delete.y, to_delete.z, GridMap.INVALID_CELL_ITEM)
		_set_state(GameStates.DROPPING_TILE)
		_tile_tween.start()


func _start_enemy_turn():

	_enemies_queue = _enemies.get_children()
	_set_state(GameStates.ENEMIES_TURN)
	_do_enemy_move()


func _do_enemy_move():

	if _enemies_queue.size() > 0:
		var enemy = _enemies_queue.pop_back()
		_camera.move_to(enemy.global_transform.origin, 0.5)
		var enemy_pos = enemy.get_grid_pos()
		var closest_person = null
		var closest_distance = 0
		var move_vec = null
		var vec = null
		for person in _people.get_children():
			var p_person = person.get_grid_pos()
			vec = p_person - enemy_pos
			var distance = vec.length_squared()
			if closest_person == null or distance < closest_distance:
				closest_person = person
				move_vec = vec
				closest_distance = distance

		if vec != null:
			var offset = Vector2(floor(clamp(move_vec.x, -1, 1)), floor(clamp(move_vec.y, -1, 1)))
			var new_pos = enemy_pos + offset
			var attacking_person = _find_person(new_pos)
			if attacking_person != null:
				attacking_person.queue_free()
				_check_state()
			enemy.move_by(offset, 0.5)

	else:
		_boat_turn()


func _boat_turn():
	_set_state(GameStates.BOAT_MOVING)
	var boat = null
	if _boats.get_children().size() > 0:
		boat = _boats.get_children()[0]

	if fmod(_turn, turns_till_boat) == 0 and boat == null:
		var new_boat = boat_scene.instance()
		new_boat.transform.origin = _boat_point.transform.origin
		_boats.add_child(new_boat)
		_end_boat_turn()
	elif boat != null:
		# _camera.move_to(boat.global_transform.origin, 0.5)
		if boat.is_full():
			# only care about getting back to exit on z axis
			var exit_pos = floor(_boat_point.transform.origin.z)
			var distance = exit_pos - boat.get_grid_pos().y
			if distance == 0:
				_set_rescue_total(_rescued_people + boat.capacity)
				boat.queue_free()
			else:
				var movement = clamp(distance, -1 * boat.move_speed, boat.move_speed)
				var offset = Vector2(0, movement)
				boat.move_by(offset, 0.5)
			_end_boat_turn()
		else:
			var nearest_cell = null
			var nearest_x = 0
			var nearest_z = 0
			var current_pos = boat.get_grid_pos()
			current_pos.y += 3 # looking ahead of boat
			var used_cells = _grid.get_used_cells()
			if used_cells.size() > 0:
				nearest_cell = used_cells[0]
				nearest_x = nearest_cell.x - current_pos.x
				nearest_z = nearest_cell.z - current_pos.y

				for cell in _grid.get_used_cells():
					var x_diff = cell.x - current_pos.x
					var z_diff = cell.z - current_pos.y
					if x_diff < nearest_x or (x_diff == nearest_x and z_diff < nearest_z):
						nearest_cell = cell
						nearest_x = x_diff
						nearest_z = z_diff

			var movement_x = clamp(nearest_x, 0, boat.move_speed)
			var movement_left = boat.move_speed - movement_x
			var movement_z = clamp(nearest_z, 0, movement_left) # subtract one as we don't want to go onto tile
			boat.move_by(Vector2(movement_x, movement_z), 0.5)


# Helpers

func _check_state():
	var _total_rescue = _rescued_people
	for boat in _boats.get_children():
		_total_rescue += boat.on_board


	var used = _grid.get_used_cells()
	var people = _people.get_children()
	var people_count = 0
	for person in people:
		if not person.is_queued_for_deletion():
			people_count += 1
	if people_count == 0 or used.size() == 0:
		_set_state(GameStates.LEVEL_OVER)
		_overlay.show(_total_rescue, _total_people)



func _is_floor_tile(pos):
	var tile = _grid.get_cell_item(pos.x, 0, pos.y)
	if tile == lowest_tile_index or tile == medium_tile_index:
		return true
	return false


func _find_person(pos):
	for person in _people.get_children():
		var grid_pos = Vector2(floor(person.transform.origin.x), floor(person.transform.origin.z))
		if grid_pos == pos:
			return person

