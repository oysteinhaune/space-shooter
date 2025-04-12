extends Node2D

signal engine_picked_up


func _on_area_2d_body_entered(_body):
	emit_signal("engine_picked_up")
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	print('engine_killed')
	queue_free()
