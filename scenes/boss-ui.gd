extends CanvasLayer

static var image = load("res://assets/sprites/PNG/UI/playerLife1_blue.png")

func set_health(amount):
	for child in $MarginContainer2/HBoxContainer.get_children():
		child.queue_free()

	for i in amount:
		var text_rect = TextureRect.new()
		text_rect.texture = image
		$MarginContainer2/HBoxContainer.add_child(text_rect)
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP

