extends Node2D


export (NodePath) var button_path := "Button"
onready var _button := get_node(button_path)

export (String, FILE) var level = null


func _ready():
	_button.connect("pressed", self, "_end")


func _end():
	var s = ResourceLoader.load(level)
	SceneSwitcher.goto_scene(s)
