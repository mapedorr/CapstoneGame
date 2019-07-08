extends CanvasLayer

func _ready():
	$Clean.hide()

func show_clean(frame = 0):
	if not $Clean.visible:
		$Clean.show()
	$Clean.texture.set_region(Rect2(
		Vector2(300 * frame, 0),
		$Clean.texture.get_size())
	)