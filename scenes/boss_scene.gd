extends Node2D

var health: int = 3
var boss_health: int = 12

var boss_laser_scene: PackedScene = load("res://scenes/boss_laser.tscn")
var laser_scene: PackedScene = load("res://scenes/laser.tscn")

func _ready():
	$Boss1Character.boss_laser.connect(_on_boss_laser)
	get_tree().call_group('ui', 'set_health', health)
	$UI/MarginContainer.queue_free()

func _on_boss_laser(pos):
	var laser = boss_laser_scene.instantiate()
	$BossLasers.add_child(laser)
	laser.position = pos

func _on_player_laser(pos):
	var laser = laser_scene.instantiate()
	$Lazers.add_child(laser)
	laser.position = pos
	
func _on_player_collision():
	if health > 0:
		$Player.play_collision_sound()
		flash_player()
	health -= 1
	get_tree().call_group('ui', 'set_health', health)
	
	if health <= 0:
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		

func _on_boss_1_character_area_entered(area):
	area.queue_free()
	boss_health -= 1
	print(boss_health)
	
	if boss_health > 0:
		flash_and_stutter_boss()

	if boss_health <= 0:
		show_victory_message()
		
		
func _input(event):
	if event.is_action_pressed("reset") && boss_health == 0:
		get_tree().change_scene_to_file("res://scenes/level.tscn")
		
func flash_player():
	var player = $Player
	var player_image = $Player/PlayerImage
	var tween = get_tree().create_tween()

	player_image.modulate = Color(1, 0, 0)

	var original_position = player.position
	tween.tween_property(player, "position", original_position + Vector2(0, -10), 0.1)
	tween.tween_property(player, "position", original_position, 0.1)

	await get_tree().create_timer(0.2).timeout  
	player_image.modulate = Color(1, 1, 1)


func flash_and_stutter_boss():
	var boss = $Boss1Character
	var boss_image = $Boss1Character/BossImage
	var tween = get_tree().create_tween()

	boss_image.modulate = Color(1, 0, 0)  
	
	var original_position = boss.position
	tween.tween_property(boss, "position", original_position + Vector2(0, -10), 0.1)
	tween.tween_property(boss, "position", original_position, 0.1)

	await get_tree().create_timer(0.2).timeout  
	boss_image.modulate = Color(1, 1, 1)

func show_victory_message():
	$Boss1Character.queue_free()
	display_initial_message()

func display_initial_message():
	var label = Label.new()
	label.text = "Good job killing the boss!"
	label.set_position(Vector2(400, 200))
	label.set("theme/font_size", 60)
	add_child(label)

	await get_tree().create_timer(4).timeout

	label.queue_free()
	display_victory_message()

func display_victory_message():
	var victory_label = Label.new()
	victory_label.text = "With the Space Boss slain, the skies clear, and a sense of peace returns to the galaxy. \n\n" + "As the hero of this realm, your journey continues. \n" + "New adventures await, filled with uncharted worlds and legendary foes. \n" + "Gather your courage, for the stars are calling, and destiny awaits!"
	victory_label.set_position(Vector2(400, 200))
	victory_label.set("theme/font_size", 40)
	add_child(victory_label)

	display_instruction_label()

func display_instruction_label():
	var instruction_label = Label.new()
	instruction_label.text = "Press Space key to continue your journey."
	instruction_label.set_position(Vector2(400, 390))
	instruction_label.set("theme/font_size", 40)
	add_child(instruction_label)


func _on_music_finished():
	$Music.play()
