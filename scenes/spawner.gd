extends Node2D

# Preload the enemy scene (this should be your enemy base scene or specific enemies)
var enemy_scene = preload("res://scenes/enemy_ship.tscn")  # Adjust path to match your scene
var laser_scene = preload("res://scenes/boss_laser.tscn")
var engine_scene = preload("res://scenes/boss_engine.tscn")
# Preload all engine textures
const ENGINE_TEXTURES = [
	preload("res://assets/sprites/PNG/Parts/engine1.png"),
	preload("res://assets/sprites/PNG/Parts/engine2.png"),
	preload("res://assets/sprites/PNG/Parts/engine3.png"),
	preload("res://assets/sprites/PNG/Parts/engine4.png"),
	preload("res://assets/sprites/PNG/Parts/engine5.png")
]

# Timer to control spawn intervals
var spawn_timer: Timer
var gap = 150  # Horizontal gap between enemies
var offset_left = -200  # Horizontal offset for variation

signal engine_collected


# Initialization
func _ready():
	# Enemy spawning
	$EnemyTimer.one_shot = false
	$EnemyTimer.connect("timeout", Callable(self, "_on_spawn_timeout"))
	$EnemyTimer.start()

	# Engine spawning
	$EngineTimer.one_shot = false  # Optional, but keeps it clear
	$EngineTimer.connect("timeout", Callable(self, "spawn_engine"))
	$EngineTimer.start()

# Function that runs every time the spawn timer times out
func _on_spawn_timeout():
	spawn_enemy()

# This function will spawn a single enemy
func spawn_enemy():
	var enemies_node = get_parent().get_node("Enemies")  # Assuming 'Enemies' is the parent node
	var enemy = enemy_scene.instantiate()

	# Randomly choose between moving down or swaying
	var random_move_type = randi() % 2  # Generates either 0 or 1
	if random_move_type == 0:
		enemy.move_type = "down"  # Move straight down
	else:
		enemy.move_type = "sway"  # Sway left and right
	
	# Add the enemy to the parent node (which will add it to the main scene)
	enemies_node.add_child(enemy)

	# Connect the signal from the enemy to handle laser firing
	enemy.connect("enemy_ship_laser", Callable(self, "_on_enemy_ship_laser"))
	
func spawn_engine():
	var engines_node = get_parent().get_node("Engines")
	var engine = engine_scene.instantiate()

	# Randomize X position within road bounds
	var road_left = 200
	var road_right = 1070
	var random_x = randf_range(road_left, road_right)

	# Start Y position above the screen
	var start_y = -engine.get_rect().size.y if engine.has_method("get_rect") else -100
	engine.global_position = Vector2(random_x, start_y)

	# Apply a random texture to the engine (assumes engine has a Sprite2D under Area2D)
	var random_texture = ENGINE_TEXTURES[randi() % ENGINE_TEXTURES.size()]
	var sprite = engine.get_node("Area2D/Sprite2D")
	if sprite and sprite is Sprite2D:
		sprite.texture = random_texture

	# Connect engine_picked_up signal
	if engine.has_signal("engine_picked_up"):
		engine.connect("engine_picked_up", Callable(self, "_on_engine_picked_up"))

	engines_node.add_child(engine)
	
func spawn_boss():
	print('spawnBoss')
	
func _on_engine_picked_up():
	emit_signal("engine_collected")
	
func _on_enemy_ship_laser(laser_position: Vector2):
	var lasers_node = get_parent().get_node("EnemyLasers")
	var laser = laser_scene.instantiate()
	laser.move_direction = 1
	laser.position = laser_position
	lasers_node.call_deferred("add_child", laser)
	
	laser.global_position = laser_position + Vector2(-14, 0)


func _on_race_scene_boss_spawned():
	spawn_boss()

func _on_race_scene_turn_off_enemies():
	$EnemyTimer.stop()
	$EngineTimer.stop()
