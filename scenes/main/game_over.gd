extends Control

#@export var level_scene: PackedScene
@onready var race_scene = preload("res://scenes/main/race_scene.tscn")

func _ready():
	$CenterContainer/VBoxContainer/Label2.text = $CenterContainer/VBoxContainer/Label2.text + str(Global.score)

func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().change_scene_to_packed(race_scene)
