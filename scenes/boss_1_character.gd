extends Area2D

signal boss_defeated
signal engine_picked_up
signal boss_hit

# Boss configuration
var speed := 500
var direction := 1
var min_x := 40
var max_x := 1200
var laser_interval := 0.2
var boss_health := 8
var boss_engine: Node = null
var boss_laser_scene: PackedScene = load("res://scenes/boss_laser.tscn")

enum BossState { IDLE, MOVING, DAMAGED, DEAD, SPAWN_ENGINE }
var current_state := BossState.IDLE

func _ready():
	position = Vector2(500, 100)
	set_state(BossState.MOVING)

	# Laser timer setup
	var laser_timer = $BossLaserTimer
	laser_timer.wait_time = laser_interval
	laser_timer.one_shot = false
	laser_timer.start()
	laser_timer.timeout.connect(Callable(self, "_on_laser_timeout"))
	area_entered.connect(_on_area_entered)

func _process(delta):
	match current_state:
		BossState.MOVING:
			move(delta)
		# Other states can have idle/delay/animation logic if needed
func set_state(new_state: BossState) -> void:
	if current_state == new_state:
		return

	current_state = new_state

	match new_state:
		BossState.IDLE:
			pass  # Pause state if needed
		BossState.MOVING:
			pass  # Nothing to initialize
		BossState.DAMAGED:
			flash_and_stutter_boss()
		BossState.DEAD:
			handle_death()
		BossState.SPAWN_ENGINE:
			spawn_boss_engine(position)

func move(delta):
	position.x += speed * direction * delta

	if position.x >= max_x:
		direction = -1
	elif position.x <= min_x:
		direction = 1

func _on_laser_timeout():
	if current_state == BossState.MOVING:
		var laser = boss_laser_scene.instantiate()
		laser.global_position = $LaserStartPos.global_position
		get_tree().current_scene.add_child(laser)

func _on_body_entered(area):
	print('boss body hit')
	if area.is_in_group("lasers"):
		print("Laser hit the boss!")
		area.queue_free()
		boss_hit.emit()

func _on_area_entered(area):
	print('boss area hit')
	print('area:', area)
	print("Groups on area:", area.get_groups())
	
	if area.is_in_group("lasers"):
		print("Laser hit the boss!")
		area.queue_free()
		boss_health -= 1
		print(boss_health)

		if boss_health > 0:
			set_state(BossState.DAMAGED)
		else:
			set_state(BossState.DEAD)

func flash_and_stutter_boss():
	var boss = self
	var boss_image = $BossImage
	var tween = get_tree().create_tween()
	var original_position = boss.position

	boss_image.modulate = Color(1, 0, 0)
	tween.tween_property(boss, "position", original_position + Vector2(0, -10), 0.1)
	tween.tween_property(boss, "position", original_position, 0.1)

	await get_tree().create_timer(0.2).timeout
	boss_image.modulate = Color(1, 1, 1)

	# Resume movement
	set_state(BossState.MOVING)

func handle_death():
	boss_defeated.emit()
	# Hide boss visuals and disable collisions, but keep node alive
	visible = false
	set_process(false)  # stop _process if you want
	set_state(BossState.SPAWN_ENGINE)
	# Spawn the engine at boss position
	spawn_boss_engine(global_position)

func spawn_boss_engine(spawn_position: Vector2) -> void:
	await get_tree().create_timer(0.1).timeout
	var boss_engine_scene = load("res://scenes/boss_engine.tscn")
	boss_engine = boss_engine_scene.instantiate()
	boss_engine.global_position = spawn_position
	get_parent().add_child(boss_engine)
	
	# Save a reference to the engine for cleanup later
	self.boss_engine = boss_engine
	
	# Connect the engine’s pickup signal to a handler
	if boss_engine.has_signal("engine_picked_up"):
		boss_engine.connect("engine_picked_up", Callable(self, "_on_engine_picked_up"))
		
func _on_engine_picked_up():
	print("Engine picked up! Transitioning scene...")
	engine_picked_up.emit()
