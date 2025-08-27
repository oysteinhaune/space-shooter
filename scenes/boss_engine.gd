extends Node2D

signal engine_picked_up
var collected = false

func _on_area_2d_body_entered(_body):
	if collected:
		return
	collected = true
	emit_signal("engine_picked_up")
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if collected:
		return
	collected = true
	print('engine_killed')
	queue_free()
