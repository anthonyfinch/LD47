extends Node


export (NodePath) var anim_path := "AnimationPlayer"
onready var _anim := get_node(anim_path)

export (NodePath) var main_text_path := "Label"
onready var _main_text := get_node(main_text_path)

export (NodePath) var button_path := "Extras/Button"
onready var _button := get_node(button_path)



func _ready():
	_button.connect("pressed", self, "_on_button_pressed")



func show(rescued, total):
	if rescued == total:
		_main_text.text = "Level Passed"
		_button.text = "Next"
	else:
		_main_text.text = "Level Failed"
		_button.text = "Retry"
	_anim.play("show")


func _on_button_pressed():
	Events.emit_signal("end_level_button_pressed")
