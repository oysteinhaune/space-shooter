extends CharacterBody2D

@export var speed := 200
var can_shoot:bool = true

signal laser(pos)
signal collision


func _ready():
	position = Vector2(100, 500)


func _process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down" )
	velocity = direction * speed
	move_and_slide()
	
	#shoot input
	if Input.is_action_pressed("shoot") and can_shoot:
		laser.emit($LaserStartPos.global_position)
		can_shoot = false
		$LaserTimer.start()
		$LaserSound.play()
	
	
func play_collision_sound():
	$DamageSound.play()


func _on_laser_timer_timeout():
	can_shoot = true


func _on_hitbox_area_entered(_area):
	collision.emit()
