extends Spatial


export (NodePath) var people_path := "People"
export (NodePath) var enemies_path := "Enemies"
export (NodePath) var boats_path := "Boats"
export (NodePath) var boat_point_path := "BoatPoint"
export (NodePath) var grid_path := "GridMap"
export (PackedScene) var boat_scene = null
export (int) var max_moves := 3
export (int) var lowest_tile_index := 1
export (int) var medium_tile_index := 2
export (int) var turns_till_boat := 3

onready var _people := get_node(people_path)
onready var _enemies := get_node(enemies_path)
onready var _grid := get_node(grid_path)
onready var _boats := get_node(boats_path)
onready var _boat_point := get_node(boat_point_path)

var _selected_person: Spatial = null
var _state = GameStates.AWAITING_PLAYER
var _moves_done := 0
var _turn := 1
var _total_people := 0
var _rescued_people := 0



enum GameStates {
	AWAITING_PLAYER,
	ENEMY_TURN
}


# Handlers

func _ready():
	Events.connect("grid_clicked", self, "_on_grid_clicked")
	Events.connect("grid_position", self, "_on_grid_position")
	Events.connect("boat_clicked", self, "_on_boat_clicked")

	_total_people = _people.get_children().size()


func _on_grid_clicked(pos):
	if _state == GameStates.AWAITING_PLAYER:
		_do_move(pos)


func _on_grid_position(pos):
	pass


func _on_boat_clicked(boat):
	if _state == GameStates.AWAITING_PLAYER:
		if _selected_person != null and not boat.is_full():
			var pos = boat.get_grid_pos()
			print(pos)
			print(_selected_person.get_grid_pos())
			var positions = [
				Vector2(pos.x, pos.y),
				Vector2(pos.x, pos.y + 1),
				Vector2(pos.x, pos.y + 2)
				]
			var already_found = false
			for boat_pos in positions:
				if not already_found:
					if _selected_person.can_move_to(boat_pos):
						_moves_done += 1
						print("embarking")
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
			# print("selected person: ", clicked)
			_selected_person = clicked
	else:
		# print("moving")
		if _selected_person.can_move_to(pos):
			if _is_floor_tile(pos):
				_selected_person.move_to(pos)
				_selected_person = null
				_moves_done += 1
				_end_player_move()


func _end_player_move():
	if _moves_done == max_moves:
		_moves_done = 0
		_state = GameStates.ENEMY_TURN
		_drop_tile()
		_do_enemy_move()
		_boat_turn()
		_state = GameStates.AWAITING_PLAYER
		_turn += 1

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
		var person = _find_person(Vector2(to_delete.x, to_delete.z))
		if person != null:
			person.queue_free()
		_grid.set_cell_item(to_delete.x, to_delete.y, to_delete.z, GridMap.INVALID_CELL_ITEM)


func _do_enemy_move():

	for enemy in _enemies.get_children():
		var enemy_pos = enemy.get_grid_pos()
		var closest_person = null
		var closest_distance = 0
		var vec = null
		for person in _people.get_children():
			var p_person = person.get_grid_pos()
			vec = p_person - enemy_pos
			var distance = vec.length_squared()
			if closest_person == null or distance < closest_distance:
				closest_person = person
				closest_distance = distance

		# print("closest person ", closest_person)

		# print(vec)
		var offset = Vector2(floor(clamp(vec.x, -1, 1)), floor(clamp(vec.y, -1, 1)))
		var new_pos = enemy_pos + offset
		var attacking_person = _find_person(new_pos)
		if attacking_person != null:
			print("Killing person:" , attacking_person)
			attacking_person.queue_free()
		enemy.move_by(offset)


func _boat_turn():
	var boat = null
	if _boats.get_children().size() > 0:
		boat = _boats.get_children()[0]

	if fmod(_turn, turns_till_boat) == 0 and boat == null:
		print("spawning boat")
		var new_boat = boat_scene.instance()
		new_boat.transform.origin = _boat_point.transform.origin
		_boats.add_child(new_boat)
	elif boat != null:
		if boat.is_full():
			print("dealing full with boat")
			# only care about getting back to exit on z axis
			var exit_pos = floor(_boat_point.transform.origin.z)
			var distance = exit_pos - boat.get_grid_pos().y
			if distance == 0:
				print("boat got out")
				boat.queue_free()
			else:
				print("I'm gonna move")
				var movement = clamp(distance, -1 * boat.move_speed, boat.move_speed)
				var offset = Vector2(0, movement)
				print(distance, movement, offset)
				boat.move_by(offset)
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
			print(nearest_cell, movement_x, movement_left, movement_z)
			boat.move_by(Vector2(movement_x, movement_z))


# Helpers

func _check_state():
	var _total_rescue = _rescued_people
	for boat in _boats.get_children():
		_total_rescue += boat.on_board


	var used = _grid.get_used_cells()
	# print("used size", used.size())
	if used.size() == 0:
		print("all tiles gone")
		print("rescued ", _total_rescue, " out of ", _total_people)

	var people = _people.get_children()
	var people_count = 0
	for person in people:
		if not person.is_queued_for_deletion():
			people_count += 1
	# print("people size", people_count)
	if people_count == 0:
		print("all people gone")
		print("rescued ", _total_rescue, " out of ", _total_people)


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

