extends Spatial


export (NodePath) var people_path := "People"
export (NodePath) var enemies_path := "Enemies"
export (NodePath) var grid_path := "GridMap"
export (int) var max_moves := 3
export (int) var lowest_tile_index := 1
export (int) var medium_tile_index := 2

onready var _people := get_node(people_path)
onready var _enemies := get_node(enemies_path)
onready var _grid := get_node(grid_path)

var _selected_person: Spatial = null
var _state = GameStates.AWAITING_PLAYER
var _moves_done := 0



enum GameStates {
	AWAITING_PLAYER,
	ENEMY_TURN
}


func _ready():
	Events.connect("grid_clicked", self, "_on_grid_clicked")
	Events.connect("grid_position", self, "_on_grid_position")


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


func _do_move(pos):
	if _selected_person == null:
		var clicked = _find_person(pos)
		if clicked != null and _is_floor_tile(pos):
			# print("selected person: ", clicked)
			_selected_person = clicked
	else:
		# print("moving")
		if _selected_person.can_move_to(pos) and _is_floor_tile(pos):
			_selected_person.move_to(pos)
			_selected_person = null
			_moves_done += 1
		if _moves_done == max_moves:
			_moves_done = 0
			_state = GameStates.ENEMY_TURN
			_enemy_turn()


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


func _enemy_turn():
	_drop_tile()
	_do_enemy_move()
	_state = GameStates.AWAITING_PLAYER


func _on_grid_clicked(pos):
	if _state == GameStates.AWAITING_PLAYER:
		_do_move(pos)

func _on_grid_position(pos):
	pass
