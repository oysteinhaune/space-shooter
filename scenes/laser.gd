extends Area2D

@export var speed = 500

func _ready():
	var tween = create_tween()
	tween.tween_property($LaserImage, 'scale', Vector2(1,1), 0.2).from(Vector2(0,0))

func _process(delta):
	position.y -= speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
