extends Control

@export var level_scene: PackedScene

func _ready():
	$CenterContainer/VBoxContainer/Label2.text = $CenterContainer/VBoxContainer/Label2.text + str(Global.score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().change_scene_to_packed(level_scene)
	
