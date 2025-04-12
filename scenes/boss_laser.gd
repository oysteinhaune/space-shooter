extends Area2D

@export var speed = 500
@export var move_direction = 1  # 1 for down (default), -1 for up

func _ready():
	add_to_group("boss_laser")
	
	var tween = create_tween()
	tween.tween_property($BossLaserImage, 'scale', Vector2(1, 1), 0.2).from(Vector2(0, 0))

	# Flip the texture if needed
	flip_texture()

func _process(delta):
	position.y += move_direction * speed * delta  # Move up or down based on move_direction

func flip_texture():
	# Flip vertically if moving up
	if move_direction == -1:
		$BossLaserImage.flip_v = true
	else:
		$BossLaserImage.flip_v = false

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.name == 'Hitbox':
		queue_free()
