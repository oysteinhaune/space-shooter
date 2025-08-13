extends CharacterBody2D

@export var speed := 200
@export var max_health := 3
var can_shoot: bool = true
var health := max_health
var laser_scene: PackedScene = load("res://scenes/laser.tscn")

signal collision
signal player_died

enum PlayerState { IDLE, MOVING, HIT, FLASHING, INVULNERABLE, DEAD }
var state = PlayerState.IDLE

func _ready():
	position = Vector2(100, 500)
	state = PlayerState.IDLE

func _process(_delta):
	match state:
		PlayerState.IDLE, PlayerState.MOVING, PlayerState.INVULNERABLE:
			handle_input()
			handle_shooting()
		PlayerState.HIT, PlayerState.FLASHING, PlayerState.DEAD:
			# No input or shooting during these states
			pass

func handle_input():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		state = PlayerState.MOVING
		velocity = direction * speed
		move_and_slide()
	else:
		state = PlayerState.IDLE
		velocity = Vector2.ZERO

func handle_shooting():
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		$LaserTimer.start()
		$LaserSound.play()
		
		var laser = laser_scene.instantiate()
		laser.position = $LaserStartPos.global_position
		$Lasers.add_child(laser)


func _on_hitbox_area_entered(_area):
	if state in [PlayerState.HIT, PlayerState.FLASHING, PlayerState.INVULNERABLE, PlayerState.DEAD]:
		return
	await take_hit()

func take_hit():
	if state == PlayerState.HIT or state == PlayerState.FLASHING or state == PlayerState.INVULNERABLE:
		return  # Prevent taking damage again
	health -= 1
	get_tree().call_group('ui', 'set_health', health)
	play_collision_sound()

	if health <= 0:
		state = PlayerState.DEAD
		emit_signal("player_died")
	else:
		state = PlayerState.INVULNERABLE

		await flash_player()
		
		$HitCooldownTimer.start()

func flash_player():
	var player_image = $PlayerImage
	var tween = get_tree().create_tween()

	player_image.modulate = Color(1, 0, 0)
	var original_position = position
	tween.tween_property(self, "position", original_position + Vector2(0, -10), 0.1)
	tween.tween_property(self, "position", original_position, 0.1)

	await tween.finished
	if is_instance_valid(player_image):
		player_image.modulate = Color(1, 1, 1)

func _on_HitCooldownTimer_timeout():
	state = PlayerState.IDLE

func _on_laser_timer_timeout():
	can_shoot = true

func play_collision_sound():
	$DamageSound.play()
