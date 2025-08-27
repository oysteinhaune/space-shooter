extends Node2D

var health: int = 3
var laser_scene: PackedScene = load("res://scenes/laser.tscn")
var is_invincible = false
var is_dead = false
signal race_level_ready

func _ready():
	get_tree().call_group('ui', 'set_health', health)
	$UI/MarginContainer.queue_free()

func show_victory_message():
	display_initial_message()

func display_initial_message():
	var label = Label.new()
	label.text = "Good job killing the boss!"
	label.set_position(Vector2(400, 200))
	label.set("theme/font_size", 60)
	add_child(label)

	await get_tree().create_timer(3).timeout
	label.queue_free()
	display_victory_message()

func display_victory_message():
	var victory_label = Label.new()
	victory_label.name = "VictoryLabel"  # Set name for easy removal
	victory_label.text = "With the Space Boss slain, the skies clear, and a sense of peace returns to the galaxy.\n\n" + \
		"As the hero of this realm, your journey continues.\n" + \
		"New adventures await, filled with uncharted worlds and legendary foes.\n" + \
		"Gather your courage, for the stars are calling, and destiny awaits!\n\n" + \
		"You claim the fallen foe's engine, a relic of war.\n" + \
		"With it, you shall navigate the asteroid field and journey to the lost world of Valtor-7...\n\n" + \
		"Move over the engine to collect it and continue your journey."

	victory_label.set_position(Vector2(250, 200))
	victory_label.add_theme_color_override("font_color", Color(1, 1, 0))  # Yellow text

	# Add to the scene
	add_child(victory_label)

func _on_music_finished():
	$Music.play()


