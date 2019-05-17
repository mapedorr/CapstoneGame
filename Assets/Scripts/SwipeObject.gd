extends TouchScreenButton

signal object_pressed

var presionado

func _on_touch_pressed():
	presionado = true
	emit_signal("object_pressed")

func _on_touch_released():
	presionado = false
	# print(get_shape().collide(transform, get_shape(), transform))