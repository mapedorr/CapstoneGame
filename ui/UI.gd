extends CanvasLayer

signal start_game

onready var cleanliness_visible = false
var hearts = 3

func _ready():
	$CleanlinessCheck.hide()
	# Connect signals
	$StartScreen/StartButtons/Start.connect("pressed", self, "_on_start_pressed")
	$StartScreen/StartButtons/Credits.connect("pressed", self, "_on_credits_pressed")
	$StartScreen/Credits/Back.connect("pressed", self, "_on_back_pressed")
	$StartScreen/AnimationPlayer.play("Show")
	yield(get_tree().create_timer(0.3), "timeout")
	$UI_Menu_In.play() 

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

func _on_start_pressed():
	# TODO: start the animation that hides the Start Screen elements
	$StartScreen/AnimationPlayer.play_backwards("Show")
	$UI_Menu_Out.play()
	yield($StartScreen/AnimationPlayer, "animation_finished")
	$StartScreen.hide()
	emit_signal("start_game")

func _on_credits_pressed():
	$StartScreen/AnimationPlayer.play("ShowCredits")
	$UI_Menu_Click.play()

func _on_back_pressed():
	$StartScreen/AnimationPlayer.play_backwards("ShowCredits")
	$UI_Menu_Back.play()