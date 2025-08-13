extends Node

enum GameState { MAIN_MENU, PLAYING, GAME_OVER }
var current_state = GameState.MAIN_MENU

var boss_scene: PackedScene = preload("res://scenes/main/boss_scene.tscn")
var level_scene: PackedScene = preload("res://scenes/main/level.tscn")
var race_scene: PackedScene = preload("res://scenes/main/race_scene.tscn")
var current_level = null
var player = null  # will be assigned when level instantiates

func _ready():
	change_state(GameState.PLAYING)
	connect_ui_signals()

func change_state(new_state):
	current_state = new_state

	match new_state:
		GameState.MAIN_MENU:
			show_main_menu()
		GameState.PLAYING:
			start_game()
		GameState.GAME_OVER:
			show_game_over()

func show_main_menu():
	print("Show Main Menu (implement UI here)")
	await get_tree().create_timer(1.0).timeout
	change_state(GameState.PLAYING)

func start_game():
	print("Starting game")
	current_level = level_scene.instantiate()
	add_child(current_level)

	await get_tree().process_frame  # Ensure the scene tree is updated before searching

	player = current_level.get_node_or_null("Player")
	if player == null:
		# Try to find the player recursively
		player = current_level.find_node("Player", true, false)

	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
		print("Connected to player_died signal.")
	else:
		print("Player node not found inside level!")

func show_game_over():
	print("Game Over! Switching to game over scene...")
	if current_level:
		current_level.queue_free()
		current_level = null
	call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")

func _on_player_died():
	change_state(GameState.GAME_OVER)
	
func connect_ui_signals():
	if current_level:
		var ui_node = current_level.get_node("UI")
		if ui_node:
			ui_node.connect("boss_level_ready", self._on_boss_level_ready)
		else:
			print("UI node not found in current_level!")
	else:
		print("Current level is not loaded yet!")

func _on_boss_level_ready():
	print("Boss level time reached! Switching to boss scene...")

	if current_level:
		current_level.queue_free()

	current_level = boss_scene.instantiate()
	add_child(current_level)

	# Small delay to ensure scene is fully loaded
	await get_tree().create_timer(0.01).timeout

	# --- Find and connect player ---
	player = current_level.get_node_or_null("Player")
	if player == null:
		player = current_level.find_node("Player", true, false)

	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
		print("Connected to Player's 'player_died' signal.")
	else:
		push_warning("Player node not found in boss scene.")

	# --- Find and connect boss ---
	var boss = current_level.get_node_or_null("Boss1Character")
	if boss == null:
		boss = current_level.find_node("Boss1Character", true, false)  # Recursive search

	if boss:
		boss.connect("engine_picked_up", Callable(self, "_on_engine_picked_up"))
		print("Connected to Boss's 'engine_picked_up' signal.")
	else:
		push_warning("Boss node not found in boss scene.")

func _on_engine_picked_up():
	print("Engine picked up! Switching to race scene.")
	call_deferred("_switch_to_race_scene")

func _switch_to_race_scene():
	if race_scene:
		if current_level:
			current_level.queue_free()

		current_level = race_scene.instantiate()
		add_child(current_level)
	else:
		push_error("race_scene is not assigned!")
		
	# --- Find and connect player ---
	player = current_level.get_node_or_null("Player")
	if player == null:
		player = current_level.find_node("Player", true, false)

	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
		print("Connected to Player's 'player_died' signal.")
	else:
		push_warning("Player node not found in boss scene.")
