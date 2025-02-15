extends Area2D

var speed = 500  # Movement speed (pixels per second)
var direction = 1  # 1 = right, -1 = left
var min_x = 300  # Left boundary
var max_x = 900  # Right boundary
signal boss_laser(pos)

# You can adjust the timer time here to control how often the lasers shoot.
var laser_interval = 0.2  # Interval for shooting lasers (1 second)

func _ready():
	position = Vector2(500, 100)  # Initial position
	# Start laser timer for repeated shooting
	var laser_timer = $"../BossLaserTimer"
	laser_timer.wait_time = laser_interval  # Control shooting interval here
	laser_timer.one_shot = false
	laser_timer.start()

	# Connect the timer's timeout signal to the shoot_laser function using Callable
	laser_timer.timeout.connect(Callable(self, "_on_laser_timeout"))

func _process(delta):
	move(delta)  # Call the move function
	# No need to call shoot_laser here anymore since it's handled by the timer.


func move(delta):
	position.x += speed * direction * delta  # Move side to side

	# Reverse direction when reaching boundaries
	if position.x >= max_x:
		direction = -1  # Move left
	elif position.x <= min_x:
		direction = 1  # Move right


# Function to shoot laser when the timer times out
func _on_laser_timeout():
	# Emit the signal to spawn the laser at the start position
	boss_laser.emit($LaserStartPos.global_position)  # Emit signal (ensure laser node exists)
