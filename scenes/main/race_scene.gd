extends Node2D # Parent node type, e.g., RaceScene

var road_spawned_count = 0 # Track how many roads have been spawned
const road = preload("res://scenes/road.tscn") # Preload road scene
const STRIPED_ROAD = preload("res://assets/sprites/Tiles/Asphalt road/road_asphalt01.png") # Preload the striped road texture
const FLAT_ROAD = preload("res://assets/sprites/Tiles/Asphalt road/road_asphalt22.png") # Preload the flat road texture

var game_over_scene = "res://scenes/main/game_over.tscn"
var player_health = 3
var is_flashing: bool = false
var is_dead: bool = false
var is_invincible = false

@export var spawn_distance: float = 128 # Distance to next road piece
@export var road_count: int = 11 # Number of roads to spawn horizontally
@export var row_count: int = 7 # Number of rows of roads to spawn
@export var initial_scroll_speed: float = 50.0 # Initial scrolling speed (pixels per second)
@export var speed_increment: float = 2.0 # How much the speed increases per second
@export var max_scroll_speed = 150 # Adjust this value as needed
var scroll_speed: float # Actual speed that will gradually increase
var road_tiles = [] # Store all road instances
var has_spawned = false
var engines_collected = 0
var slowing_down = false
var slowdown_timer = 0.0
var slowdown_duration = 8.0
var boss_spawn_triggered = false


signal boss_spawned
signal turn_off_enemies
signal end_of_game

func _ready():
	get_tree().call_group('ui', 'set_health', player_health)
	$UI/MarginContainer.queue_free()
	scroll_speed = initial_scroll_speed # Set initial speed
	spawn_initial_roads() # Spawn initial roads when the scene starts

	# Position the player at the middle horizontally and 3/4 down the screen
	var viewport = get_viewport_rect().size
	$Player.position = Vector2(viewport.x / 2, viewport.y * 0.75)
	set_process(true)
	
func _process(delta):
	# Move roads downward
	for road_tile in road_tiles:
		road_tile.global_position.y += scroll_speed * delta

		if road_tile.global_position.y > row_count * spawn_distance:
			road_tile.global_position.y -= (row_count + 1) * spawn_distance
	
	# Move drops in Engines
	for drop in $Engines.get_children():
		drop.global_position.y += scroll_speed * delta

	# Gradually increase speed if not slowing down
	if not slowing_down:
		scroll_speed += speed_increment * delta
		scroll_speed = min(scroll_speed, max_scroll_speed)
	else:
		emit_signal("turn_off_enemies")
		slowdown_timer += delta
		var t = clamp(slowdown_timer / slowdown_duration, 0, 1)
		scroll_speed = lerp(initial_scroll_speed, 0.0, t)

		if t >= 1.0 and not boss_spawn_triggered:
			boss_spawn_triggered = true
			print("Scroll speed is zero! Preparing to spawn boss...")
			await get_tree().create_timer(4.0).timeout
			spawn_boss()
			
func spawn_boss():
	print("Boss is spawning now!")

	var boss_scene = load("res://scenes/boss_2_character.tscn")
	var boss_instance = boss_scene.instantiate()

	var boss_node = get_node("Boss") # Adjust path if needed
	boss_node.add_child(boss_instance)

	boss_instance.position = Vector2(get_viewport_rect().size.x / 2, -100)

	# Connect to the boss_defeated signal
	if boss_instance.has_signal("boss_defeated"):
		boss_instance.connect("boss_defeated", Callable(self, "_on_boss_killed"))


	emit_signal("boss_spawned")

	# Wait for 2 seconds, then call move_down manually
	await get_tree().create_timer(2.0).timeout

	if boss_instance.has_method("move_down"):
		boss_instance.move_down(0)
		
func _on_boss_killed():
	emit_signal("end_of_game")
	
func _spawn_engine_drop(drop_position: Vector2) -> void:
	var engine_scene = load("res://scenes/boss_engine.tscn")
	var engine_instance = engine_scene.instantiate()

	var engines_node = get_tree().current_scene.get_node("Engines")
	engines_node.add_child(engine_instance)

	engine_instance.global_position = drop_position

	if engine_instance.has_signal("engine_picked_up"):
		engine_instance.connect("engine_picked_up", Callable(self, "_on_engine_picked_up"))
		
func _on_engine_picked_up():
	print("Engine picked up, loading WaterWorld scene...")
	call_deferred("_go_to_waterworld")
	
func _go_to_waterworld():
	get_tree().change_scene_to_file("res://scenes/waterworld.tscn")
		
func start_slowdown():
	if not slowing_down:
		slowing_down = true
		slowdown_timer = 0.0
		initial_scroll_speed = scroll_speed

func spawn_initial_roads():
	# Spawn an **extra row** on the top to ensure smooth scrolling
	for i in range(road_count): # Loop through 11 columns of roads
		for j in range(row_count + 1): # Extra row at the **top**
			var new_road = spawn_road(i, j - 1) # Offset by -1 so extra row is above
			road_tiles.append(new_road) # Store reference for movement

func spawn_road(index: int, row: int):
	# Instantiate the road and position it relative to the last one
	var new_road = road.instantiate() # Create a new road instance from the packed scene
	new_road.global_position = Vector2(index * spawn_distance, row * spawn_distance) # Position the road

	# Default texture is the flat road (FLAT_ROAD)
	var texture_to_use = FLAT_ROAD
	
	# Set striped texture for the 2nd and 10th roads (index 1 and index 9)
	if index == 1 or index == 9:
		texture_to_use = STRIPED_ROAD

	# Assign the texture to the road
	var sprite = new_road.get_node("Sprite") # Assuming the road has a "Sprite" node
	sprite.texture = texture_to_use # Assign the selected texture to the sprite

	$Roads.add_child(new_road) # Add the new road to the Roads node
	return new_road # Return reference to store in list

func _on_spawner_engine_collected():
	engines_collected += 1
	print("racescene engine_collected: ", engines_collected)

	if engines_collected == 4:
		print("4 engines collected! Slowing down scroll speed.")
		start_slowdown()
