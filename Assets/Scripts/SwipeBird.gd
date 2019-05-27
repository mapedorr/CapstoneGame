extends TouchScreenButton

onready var _swipe_directions = $SwipeDetector.Directions

func _ready():
	# Connect signals
	$SwipeDetector.connect("swipe_started", self, "_on_swipe_started")
	$SwipeDetector.connect("swipe_ended", self, "_on_swipe_ended")
	$SwipeDetector.connect("swiped", self, "_on_swiped")
	pass

func _on_swipe_started(partial_gesture):
	print("xxx ", partial_gesture.get_area().get_name().to_lower())


func _on_swipe_ended(partial_gesture):
	pass


func _on_swiped(gesture):
	var target = self.get_position()
	match gesture.get_direction():
		_swipe_directions.DIRECTION_LEFT:
			target.x = -get_viewport_rect().size.x
		_swipe_directions.DIRECTION_UP:
			target.y = -get_viewport_rect().size.y
		_swipe_directions.DIRECTION_DOWN:
			target.y = get_viewport_rect().size.y + 200.0
		_swipe_directions.DIRECTION_RIGHT:
			target.x = get_viewport_rect().size.x + 200.0
	$GoOut.interpolate_property(
		self,
		"position",
		self.get_position(),
		target,
		1.0,
		$GoOut.TRANS_SINE,
		$GoOut.EASE_OUT
	)
	$GoOut.start()
