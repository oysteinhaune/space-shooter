extends Area2D

@export var speed = 500
@export var move_direction = -1  # 1 for down, -1 for up (default is up)

func _ready():
	var tween = create_tween()
	tween.tween_property($LaserImage, 'scale', Vector2(1,1), 0.2).from(Vector2(0,0))
	
	# Flip the texture based on move_direction
	flip_texture()

func _process(delta):
	position.y += move_direction * speed * delta  # Move up or down based on move_direction

func flip_texture():
	# If moving down, flip the texture vertically
	if move_direction == 1:
		$LaserImage.flip_v = true  # Flip vertically to point down
	else:
		$LaserImage.flip_v = false  # Keep the texture facing upwards

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.name != 'BossLaser':
		queue_free()
