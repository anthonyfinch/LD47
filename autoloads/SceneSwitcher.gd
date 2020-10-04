extends Node


var current_scene = null


func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(packed_scene):
    call_deferred("_deferred_goto_scene", packed_scene)


func _deferred_goto_scene(packed_scene):
    current_scene.free()

    # var s = ResourceLoader.load(path)
    current_scene = packed_scene.instance()

    get_tree().get_root().add_child(current_scene)
    get_tree().set_current_scene(current_scene)
