extends Area2D

# Signal to be emitted when the player is hit by the laser
signal laser_hit

func _ready():
	print("hi")
	
	# Get the parent node (assuming this Area2D is inside the player)



# This function is triggered when something enters the Area2D's shape
func _on_area_entered(area):
	laser_hit.emit()
	print("hiee")

