extends CanvasLayer

static var image = load("res://assets/sprites/PNG/UI/playerLife1_blue.png")
var time_elapsed := 0
signal boss_level_ready

enum UIState { IDLE, UPDATING_HEALTH, TRACKING_TIME }
var state = UIState.IDLE

func _ready():
	state = UIState.IDLE

func set_health(amount):
	state = UIState.UPDATING_HEALTH
	_update_health_display(amount)
	state = UIState.IDLE

func _update_health_display(amount):
	# Clear existing health icons
	for child in $MarginContainer2/HBoxContainer.get_children():
		child.queue_free()
	# Add new health icons
	for i in amount:
		var text_rect = TextureRect.new()
		text_rect.texture = image
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP
		$MarginContainer2/HBoxContainer.add_child(text_rect)

func _on_score_timer_timeout():
	time_elapsed += 1
	$MarginContainer/Label.text = str(time_elapsed)
	Global.score = time_elapsed
	
	if time_elapsed == 30:
		emit_signal("boss_level_ready")
