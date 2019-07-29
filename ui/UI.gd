extends CanvasLayer

onready var cleanliness_visible = false
var hearts = 3

func _ready():
	$CleanlinessCheck.hide()

func show_cleanliness_check(frame = 0):
	$CleanlinessCheck/Bird.change_frame(frame)
	if not cleanliness_visible:
		$Show.play()
		cleanliness_visible = true
		$CleanlinessCheck.show()
		$CleanlinessCheck.propagate_call("play_animation")
		$Animations.play("ShowCleanlinessCheck")
	else:
		get_node("CleanlinessCheck/Heart%d" % (4 - frame)).play_animation("Break")
		match hearts:
			3:
				$Heart.play()
				hearts -= 1
			2:
				$Heart2.play()
				hearts -= 1
			1:
				$Heart3.play()
				hearts -= 1

func hide_cleanliness_check():
	if cleanliness_visible:
		hearts = 3
		$Hide.play()
		$Animations.play_backwards("ShowCleanlinessCheck")
		yield($Animations, "animation_finished")
		$CleanlinessCheck.propagate_call("stop_animation")
		cleanliness_visible = false
		$CleanlinessCheck.hide()