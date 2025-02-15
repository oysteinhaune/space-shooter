extends Area2D

var speed: int
var rotation_speed: int
var direction_x: float

signal collision
var can_collide := true

func _ready():
	var rng := RandomNumberGenerator.new()
	
	# texture
	var path: String = "res://assets/sprites/PNG/Meteors/" + str(rng.randi_range(1, 10)) +  ".png"
	$MeteorImage.texture = load(path)

	var width = get_viewport().get_visible_rect().size[0]
	var random_x = rng.randi_range(0, width)
	var random_y = rng.randi_range(-150, -50)
	position = Vector2(random_x, random_y)
	
	speed = rng.randi_range(200, 500)
	direction_x = rng.randf_range(-1, 1)
	rotation_speed = rng.randi_range(40, 100)
	
	await get_tree().create_timer(8).timeout
	queue_free()
	
func _process(delta):
	position += Vector2(direction_x, 1.0) * speed * delta
	rotation_degrees += rotation_speed * delta

func _on_body_entered(_body):
	print("collide")
	if can_collide:
		collision.emit()

func _on_area_entered(area):
	print("collide")
	area.queue_free()
	$ExplosionSound.play()
	$MeteorImage.hide()
	can_collide = false
	await get_tree().create_timer(1).timeout
	queue_free()
