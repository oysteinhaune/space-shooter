extends Node2D

var health: int = 3
var boss_health: int = 30

var boss_laser_scene: PackedScene = load("res://scenes/boss_laser.tscn")
var laser_scene: PackedScene = load("res://scenes/laser.tscn")

func _ready():
	$Boss1Character.boss_laser.connect(_on_boss_laser)

func _on_boss_laser(pos):
	var laser = boss_laser_scene.instantiate()
	$BossLasers.add_child(laser)
	laser.position = pos

func _on_player_laser(pos):
	var laser = laser_scene.instantiate()
	$Lazers.add_child(laser)
	laser.position = pos
	
func _on_player_collision():
	health -= 1
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	$Player.play_collision_sound()	

func _on_boss_1_character_area_entered(area):
	boss_health -= 1
	print(boss_health)
	if boss_health <= 0:
		get_tree().change_scene_to_file("res://scenes/level.tscn")

