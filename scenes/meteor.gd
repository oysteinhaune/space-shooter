extends Area2D

var speed: int
var rotation_speed: int
var direction_x: float

signal collision
var can_collide := true
var alive_time := 0.0
var checked_visibility := false
const MAX_LIFETIME := 9.0

func _ready():
	var rng := RandomNumberGenerator.new()
	set_random_texture(rng)
	set_random_position(rng)
	set_random_movement(rng)
	
func set_random_texture(rng: RandomNumberGenerator):
	var path: String = "res://assets/sprites/PNG/Meteors/" + str(rng.randi_range(1, 8)) + ".png"
	var texture = load(path)
	$MeteorImage.texture = texture
	
	# Update CollisionShape2D size to match texture
	if texture and $CollisionShape2D.shape is RectangleShape2D:
		var rect_shape = $CollisionShape2D.shape as RectangleShape2D
		rect_shape.extents = texture.get_size() / 2  # extents = half-size

func set_random_position(rng: RandomNumberGenerator):
	var width = get_viewport().get_visible_rect().size[0]
	var random_x = rng.randi_range(0, width)
	var random_y = rng.randi_range(-150, -50)
	position = Vector2(random_x, random_y)

func set_random_movement(rng: RandomNumberGenerator):
	speed = rng.randi_range(200, 500)
	direction_x = rng.randf_range(-1, 1)
	rotation_speed = rng.randi_range(40, 100)


func _process(delta):
	alive_time += delta
	if alive_time >= MAX_LIFETIME:
		queue_free()
	position += Vector2(direction_x, 1.0) * speed * delta
	rotation_degrees += rotation_speed * delta
	
	if alive_time >= 3.0 and not checked_visibility:
		if not is_on_screen():
			queue_free()
		checked_visibility = true  # only check once

func _on_body_entered(_body):
	if can_collide:
		collision.emit()

func _on_area_entered(area):
	if area.name == "Laser" and can_collide:
		can_collide = false  # prevent multiple triggers
		$ExplosionSound.play()
		$MeteorImage.hide()

		# Defer disabling the collider
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)

		await get_tree().create_timer(2).timeout

		if is_instance_valid(area):
			area.queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func is_on_screen() -> bool:
	var screen_rect = get_viewport().get_visible_rect()
	return screen_rect.has_point(global_position)
