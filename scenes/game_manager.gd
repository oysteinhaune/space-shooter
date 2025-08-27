extends Node

enum GameState { MAIN_MENU, PLAYING_LEVEL_1, PLAYING_LEVEL_2, PLAYING_LEVEL_3, GAME_OVER }
var current_state = GameState.MAIN_MENU

var start_scene: PackedScene = preload("res://scenes/main/start_scene.tscn")
var boss_scene: PackedScene = preload("res://scenes/main/boss_scene.tscn")
var level_scene: PackedScene = preload("res://scenes/main/level.tscn")
var race_scene: PackedScene = preload("res://scenes/main/race_scene.tscn")
var game_over_scene: PackedScene = preload("res://scenes/main/game_over.tscn")
var current_level = null
var player = null
var engine_collected = false

func _ready():
	change_state(GameState.MAIN_MENU)
	

func change_state(new_state):
	match new_state:
		GameState.MAIN_MENU:
			load_main_menu()
		GameState.PLAYING_LEVEL_1:
			load_level1()
		GameState.PLAYING_LEVEL_2:
			load_level2()
		GameState.PLAYING_LEVEL_3:
			load_level3()
		GameState.GAME_OVER:
			show_game_over()

func load_level1():
	if current_level:
		current_level.queue_free()
	
	current_level = level_scene.instantiate()
	print(current_level)
	if !current_level:
		print("Current level failed to instantiate!")
		return

	# Add to LevelContainer instead of root
	$LevelContainer.add_child(current_level)

	# Wait one frame so children are ready
	await get_tree().process_frame

	# --- Connect UI ---
	print('findUINODE')
	var ui_node = find_node_recursive(current_level, "UI")
	print(ui_node, 'ui')
	if ui_node:
		print(ui_node)
		ui_node.connect("boss_level_ready", Callable(self, "_on_boss_level_ready"))
		print("Connected UI -> boss_level_ready")
	else:
		print("UI node not found in current_level!")

	# --- Connect Player ---
	player = find_node_recursive(current_level, "Player")
	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
		print("Connected Player -> player_died")
	else:
		print("Player node not found in current_level!")

func show_game_over():
	if current_level:
		current_level.queue_free()
		current_level = null

	current_level = game_over_scene.instantiate()

	$LevelContainer.add_child(current_level)
	await get_tree().process_frame
	
	var gameover_node = find_node_recursive(current_level, "GameOver")
	
	if gameover_node:
		print(gameover_node)
		gameover_node.connect("game_restart", Callable(self, "_on_game_restart"))
	
func load_main_menu():
	if current_level:
		current_level.queue_free()
		current_level = null

	current_level = start_scene.instantiate()
	$LevelContainer.add_child(current_level)

	await get_tree().process_frame

	var start_node = find_node_recursive(current_level, "Start")

	if start_node:
		start_node.connect("start_game_pressed", Callable(self, "_on_start_pressed"))
		print("Connected to Start node signal")
	else:
		print("Start node not found in main menu scene!")
		
func find_node_recursive(root: Node, name: String) -> Node:
	if root.name == name:
		return root
	for child in root.get_children():
		var result = find_node_recursive(child, name)
		if result != null:
			return result
	return null
	
func connect_signal_if_exists(root: Node, node_name: String, signal_name: String, target: Object, method_name: String):
	var node = find_node_recursive(root, node_name)
	if node:
		node.connect(signal_name, Callable(target, method_name))
		print("Connected signal", signal_name, "from", node_name)
	else:
		print("Warning: node", node_name, "not found to connect", signal_name)
		
func _on_start_pressed():
	change_state(GameState.PLAYING_LEVEL_1)
	
func _on_game_restart():
	change_state(GameState.PLAYING_LEVEL_1)

func change_scene():
	get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")

func _on_player_died():
	change_state(GameState.GAME_OVER)
	
func _on_boss_level_ready():
	change_state(GameState.PLAYING_LEVEL_2)

func _on_end_of_game():
	change_state(GameState.MAIN_MENU)
	
func load_level2():
	print("Boss level time reached! Switching to boss scene...")

	if current_level:
		current_level.queue_free()

	current_level = boss_scene.instantiate()
	$LevelContainer.add_child(current_level)  # <- add to LevelContainer

	# Small delay to ensure scene is fully loaded
	await get_tree().create_timer(0.01).timeout

	# --- Find and connect player ---
	player = current_level.get_node_or_null("Player")
	if player == null:
		player = find_node_recursive(current_level, "Player")

	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))
		print("Connected Player's 'player_died' signal.")
	else:
		push_warning("Player node not found in boss scene.")

	# --- Find and connect boss ---
	var boss = current_level.get_node_or_null("Boss1Character")
	if boss == null:
		boss = find_node_recursive(current_level, "Boss1Character")  # Recursive search

	if boss:
		boss.connect("engine_picked_up", Callable(self, "_on_engine_picked_up"))

func _on_engine_picked_up():
	if engine_collected:
		return
	engine_collected = true

	print('onenginepickedup')
	change_state(GameState.PLAYING_LEVEL_3)

func load_level3():
	print("Loading Race Scene...")

	if current_level:
		current_level.queue_free()
		await get_tree().process_frame  # Wait one frame for queued node to actually be removed

	current_level = race_scene.instantiate()
	$LevelContainer.add_child(current_level)  # Add to LevelContainer like other levels

	# Wait a tiny moment to ensure the scene is fully added
	await get_tree().process_frame

	# --- Find and connect player ---
	player = current_level.get_node_or_null("Player")
	if player == null:
		player = find_node_recursive(current_level, "Player")

	if player:
		player.connect("player_died", Callable(self, "_on_player_died"))

	# --- Find and connect RaceScene node ---
	var racenode = current_level.get_node_or_null("RaceScene")
	if racenode == null:
		racenode = find_node_recursive(current_level, "RaceScene")

	if racenode:
		racenode.connect("end_of_game", Callable(self, "_on_end_of_game"))
