extends Area2D  # The root node can be Area2D or whatever is appropriate for your scene

@export var spawn_distance: float = 600  # Distance to the next road piece

func _ready():
	spawn_roads()  # Spawn 5 roads when the scene is ready

func spawn_roads():
	# Loop to spawn 5 roads side by side
	for i in range(5):  # Loop 5 times to spawn 5 roads
		var new_road = load("res://scenes/road.tscn").instantiate()  # Instantiate the road scene
		new_road.global_position = global_position + Vector2(spawn_distance * i, 0)  # Position the next road side by side
		get_parent().add_child(new_road)  # Add the new road to the parent node (Roads)
