extends Area2D

@export var speed = 500



func _ready():
	add_to_group("boss_laser")
	var tween = create_tween()
	tween.tween_property($BossLaserImage, 'scale', Vector2(1,1), 0.2).from(Vector2(0,0))

func _process(delta):
	position.y += speed * delta  # This moves the object down
