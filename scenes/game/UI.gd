extends Node2D


export (NodePath) var status_path := "Status"
onready var _status := get_node(status_path)
export (NodePath) var rescue_count_path := "RescueCount"
onready var _rescue_count := get_node(rescue_count_path)


var _rescue_total := 0
var _people_total := 0



func _ready():
	Events.connect("rescue_total_set", self, "_on_rescue_set")
	Events.connect("people_total_set", self, "_on_people_set")
	Events.connect("state_set", self, "_on_state")


func _on_rescue_set(count):
	_rescue_total = count
	_update_rescue_label()


func _on_people_set(count):
	_people_total = count
	_update_rescue_label()


func _on_state(state):
	_status.text = state


func _update_rescue_label():
	var msg = "%s / %s Rescued" % [_rescue_total, _people_total]
	_rescue_count.text = msg
