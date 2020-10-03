extends Spatial


export (NodePath) var people_path := "People"
export (NodePath) var grid_path := "GridMap"
onready var _people := get_node(people_path)
onready var _grid := get_node(grid_path)
var _selected_person: Spatial = null

onready var _enemy = get_node("Enemies/Enemy")
var _player_go = true


func _ready():
	Events.connect("grid_clicked", self, "_on_grid_clicked")
	Events.connect("grid_position", self, "_on_grid_position")


func _find_person(pos):
	for person in _people.get_children():
		var grid_pos = Vector2(floor(person.transform.origin.x), floor(person.transform.origin.z))
		if grid_pos == pos:
			return person

func _do_move(pos):
	if _selected_person == null:
		var clicked = _find_person(pos)
		if clicked != null:
			# print("selected person: ", clicked)
			_selected_person = clicked
	else:
		# print("moving")
		_selected_person.move_to(pos)
		_selected_person = null
		_player_go = false


func _drop_tile(pos):
	var tile = _grid.get_cell_item(pos.x, 0, pos.y)
	if tile == 0:
		_grid.set_cell_item(pos.x, 0, pos.y, GridMap.INVALID_CELL_ITEM)


func _do_enemy_move():
	var enemy_pos = Vector2(_enemy.transform.origin.x, _enemy.transform.origin.z)
	var closest_person = null
	var closest_distance = 0
	var vec = null
	for person in _people.get_children():
		var p_person = Vector2(person.transform.origin.x, person.transform.origin.z)
		vec = p_person - enemy_pos
		var distance = vec.length_squared()
		if closest_person == null or distance < closest_distance:
			closest_person = person
			closest_distance = distance

	# print("closest person ", closest_person)

	# print(vec)
	var offset = Vector2(floor(clamp(vec.x, -1, 1)), floor(clamp(vec.y, -1, 1)))
	_enemy.move_by(offset)
	_player_go = true


func _on_grid_clicked(pos):
	if _player_go:
		_do_move(pos)
	else:
		_drop_tile(pos)
		_do_enemy_move()


func _on_grid_position(pos):
	# print("over")
	pass
