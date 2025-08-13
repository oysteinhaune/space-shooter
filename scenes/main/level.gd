extends Node2D

signal game_over

enum LevelState { PLAYING, GAME_OVER }
var current_state = LevelState.PLAYING

var meteor_scene: PackedScene = load("res://scenes/meteor.tscn")
var laser_scene: PackedScene = load("res://scenes/laser.tscn")

func _ready():
	var size := get_viewport().get_visible_rect().size
	var rng := RandomNumberGenerator.new()
	for star in $Stars.get_children():
		var random_x = rng.randi_range(0, int(size.x))
		var random_y = rng.randi_range(0, int(size.y))
		star.position = Vector2(random_x, random_y)
		
		var random_scale = rng.randf_range(1, 2)
		star.scale = Vector2(random_scale, random_scale)
		
		star.speed_scale = rng.randf_range(0.6, 1.4)

func _on_meteor_timer_timeout():
	if current_state != LevelState.PLAYING:
		return  # only spawn meteors while playing
	
	var meteor = meteor_scene.instantiate()
	$Meteors.add_child(meteor)

func change_state(new_state):
	current_state = new_state
	
	match new_state:
		LevelState.PLAYING:
			$MeteorTimer.start()
		LevelState.GAME_OVER:
			$MeteorTimer.stop()
