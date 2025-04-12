extends Node2D

@export var move_speed: float = 200.0  # Vertical speed
@export var oscillation_amplitude: float = 120.0  # How far left/right to sway
@export var move_type: String = "sway"  # "sway" or "down" (default is sway)
@export var spread: float = 200.0  # Max distance from center, adjustable in Inspector
var time: float = 0.0  # For sine wave movement
var start_x: float  # X center to oscillate around
@export var horizontal_offset_range: float = 200.0  # How much left or right from the center
@onready var laser_timer = $LaserTimer  # Assuming this is your timer node

signal enemy_ship_laser(position: Vector2)
signal enemy_ship_hit(position: Vector2)



func _ready():
	var screen_size = get_viewport_rect().size
	var center_x = screen_size.x / 2

	# Randomize start_x within the defined range from the center
	start_x = center_x + randf_range(-horizontal_offset_range, horizontal_offset_range)

	# Set the initial position, just above the screen
	position = Vector2(start_x, -100)

	laser_timer.timeout.connect(_on_laser_timeout)  # Connect to your timer event


func _process(delta):
	if move_type == "sway":
		# Sway side to side with a sine wave
		position.x = start_x + sin(time) * oscillation_amplitude
		time += delta * 2.0  # Advance sine wave time
		# Still move down
		position.y += move_speed * delta
	elif move_type == "down":
		# Straight down movement without any sway
		position.y += move_speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(_body):
	enemy_ship_laser.emit(position)
	queue_free()
	

func _on_laser_timeout():
	enemy_ship_laser.emit(position)

func _on_area_entered(area):
	if area.name == 'Laser':
		queue_free()

