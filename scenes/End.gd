extends Node2D


export (NodePath) var button_path := "Button"
onready var _button := get_node(button_path)

export (PackedScene) var level = null


func _ready():
	_button.connect("pressed", SceneSwitcher, "goto_scene", [level])
