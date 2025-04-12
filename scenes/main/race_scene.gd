extends Node2D  # Parent node type, e.g., RaceScene

var road_spawned_count = 0  # Track how many roads have been spawned
const road = preload("res://scenes/road.tscn")  # Preload road scene
const STRIPED_ROAD = preload("res://assets/sprites/Tiles/Asphalt road/road_asphalt01.png")  # Preload the striped road texture
const FLAT_ROAD = preload("res://assets/sprites/Tiles/Asphalt road/road_asphalt22.png")  # Preload the flat road texture

var player_laser_scene: PackedScene = load("res://scenes/laser.tscn")
var game_over_scene = "res://scenes/main/game_over.tscn"
var player_health = 3
var is_flashing: bool = false
var is_dead: bool = false

@export var spawn_distance: float = 128  # Distance to next road piece
@export var road_count: int = 11  # Number of roads to spawn horizontally
@export var row_count: int = 7  # Number of rows of roads to spawn
@export var initial_scroll_speed: float = 50.0  # Initial scrolling speed (pixels per second)
@export var speed_increment: float = 2.0  # How much the speed increases per second
@export	var max_scroll_speed = 150  # Adjust this value as needed
var scroll_speed: float  # Actual speed that will gradually increase
var road_tiles = []  # Store all road instances
var has_spawned = false
var engines_collected = 0


func _ready():
	scroll_speed = initial_scroll_speed  # Set initial speed
	spawn_initial_roads()  # Spawn initial roads when the scene starts

	# Position the player at the middle horizontally and 3/4 down the screen
	var viewport = get_viewport_rect().size
	$Player.position = Vector2(viewport.x / 2, viewport.y * 0.75)
	set_process(true)
	
func _process(delta):
	# Move roads downward
	for road_tile in road_tiles:
		road_tile.global_position.y += scroll_speed * delta  # Move road down

		# If road moves out of view, reposition it at the **top**
		if road_tile.global_position.y > row_count * spawn_distance:
			road_tile.global_position.y -= (row_count + 1) * spawn_distance  # Wrap back to top
	
	# Move drops in Engines
	for drop in $Engines.get_children():
		drop.global_position.y += scroll_speed * delta
	
	# Gradually increase speed, but clamp it to max_scroll_speed
	scroll_speed += speed_increment * delta
	scroll_speed = min(scroll_speed, max_scroll_speed)  # Ensure it doesn't exceed max_scroll_speed
	
func _on_player_laser(pos):
	var laser = player_laser_scene.instantiate()
	$Lazers.add_child(laser)
	laser.position = pos

func spawn_initial_roads():
	# Spawn an **extra row** on the top to ensure smooth scrolling
	for i in range(road_count):  # Loop through 11 columns of roads
		for j in range(row_count + 1):  # Extra row at the **top**
			var new_road = spawn_road(i, j - 1)  # Offset by -1 so extra row is above
			road_tiles.append(new_road)  # Store reference for movement

func spawn_road(index: int, row: int):
	# Instantiate the road and position it relative to the last one
	var new_road = road.instantiate()  # Create a new road instance from the packed scene
	new_road.global_position = Vector2(index * spawn_distance, row * spawn_distance)  # Position the road

	# Default texture is the flat road (FLAT_ROAD)
	var texture_to_use = FLAT_ROAD
	
	# Set striped texture for the 2nd and 10th roads (index 1 and index 9)
	if index == 1 or index == 9:
		texture_to_use = STRIPED_ROAD

	# Assign the texture to the road
	var sprite = new_road.get_node("Sprite")  # Assuming the road has a "Sprite" node
	sprite.texture = texture_to_use  # Assign the selected texture to the sprite

	$Roads.add_child(new_road)  # Add the new road to the Roads node
	return new_road  # Return reference to store in list

func _on_player_collision() -> void:
	player_health -= 1
	await flash_player()   # Wait for tween to finish

	if player_health == 0:
		await get_tree().create_timer(1.0).timeout
		change_scene()

func change_scene():
	call_deferred("_deferred_change_scene")

func _deferred_change_scene():
	get_tree().change_scene_to_file(game_over_scene)
	
func flash_player() -> void:
	if is_flashing:
		return
	is_flashing = true

	var player = $Player
	var player_image = $Player/PlayerImage
	var tween = get_tree().create_tween()

	player_image.modulate = Color(1, 0, 0)

	var original_position = player.position
	tween.tween_property(player, "position", original_position + Vector2(0, -10), 0.1)
	tween.tween_property(player, "position", original_position, 0.1)

	await tween.finished
	player_image.modulate = Color(1, 1, 1)

	is_flashing = false


func _on_spawner_engine_collected():
	engines_collected += 1
	print('racescene engine_collected: ', engines_collected )
