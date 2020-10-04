extends Spatial


export (PackedScene) var level = null
export (NodePath) var person_path := "People/Person"
onready var _person := get_node(person_path)
export (NodePath) var button_path := "Button"
onready var _button := get_node(button_path)



func _ready():
	_person.activate()
	_button.connect("pressed", SceneSwitcher, "goto_scene", [level])
