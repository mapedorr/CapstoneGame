extends TouchScreenButton



func _on_SwipeDetector_swipe_started(partial_gesture):
	print("Se inicia el Swipe")


func _on_SwipeDetector_swipe_ended(gesture):
	print("Se termina el Swipe")


func _on_SwipeDetector_swiped(gesture):
	print(gesture.get_direction())
