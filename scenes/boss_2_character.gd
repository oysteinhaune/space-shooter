extends Area2D

var speed = 500  # Movement speed (pixels per second)
var direction = 1  # 1 = right, -1 = left
var min_x = 40  # Left boundary
var max_x = 1200  # Right boundary
var target_y = 100
var entry_speed = 100
var has_entered_screen = false
var boss_health = 8

signal boss_laser(pos)
signal boss_defeated
@onready var level_scene = preload("res://scenes/main/level.tscn")

# You can adjust the timer time here to control how often the lasers shoot.
var laser_interval = 0.2  # Interval for shooting lasers (1 second)

func _ready():
	var viewport_rect = get_viewport_rect()
	position = Vector2(viewport_rect.size.x / 2, -100)  # Spawn just above the top center of the screen
	var laser_timer = $BossLaserTimer
	laser_timer.wait_time = laser_interval  # Control shooting interval here
	laser_timer.one_shot = false
	laser_timer.start()

	# Connect the timer's timeout signal to the shoot_laser function using Callable
	laser_timer.timeout.connect(Callable(self, "_on_laser_timeout"))
	area_entered.connect(_on_area_entered)

	

func _process(delta):
	if not has_entered_screen:
		move_down(delta)


func move_down(delta):
	if not has_entered_screen:
		position.y += entry_speed * delta
		if position.y >= target_y:
			position.y = target_y
			has_entered_screen = true


# Function to shoot laser when the timer times out
func _on_laser_timeout():
	var laser_scene = preload("res://scenes/boss_laser.tscn")
	var laser_instance = laser_scene.instantiate()
	laser_instance.position = global_position + Vector2(0, 50)  # Adjust offset if needed

	# Find the BossLasers node in the scene
	var laser_container = $BossLasers

	if laser_container:
		laser_container.add_child(laser_instance)
	else:
		print("BossLasers node not found!")
	
func _on_body_entered(area):
	print(area)
	if area.is_in_group("lasers"):
		print("Laser hit the boss!")
		area.queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name.begins_with("Laser"):
		boss_health -= 1
		print("Boss hit! Health:", boss_health)

		area.queue_free()

		if boss_health <= 0:
			get_tree().change_scene_to_packed(level_scene)
			queue_free()
	

