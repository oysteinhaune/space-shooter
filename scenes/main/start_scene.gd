extends Control

#@export var level_scene: PackedScene
@onready var level_scene = preload("res://scenes/main/level.tscn")

signal start_game_pressed

func _input(event):
	if event.is_action_pressed("reset"):
		emit_signal("start_game_pressed")
