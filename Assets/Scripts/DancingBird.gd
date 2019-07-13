extends TouchScreenButton

export(int) var cuando = 1
var face = -1.0
var count = 2
var pre_count = 0
onready var normal_texture = get_texture()

func _ready():
	$SpeechBalloon.hide()

func dance():
	pre_count += 1
	if pre_count == 2:
		pre_count = 0
		if cuando == count:
			$Dance.play("Dance")
			# set_scale(Vector2(get_scale().x * face, get_scale().y))
			$Chirp.play()
			set_texture(pressed)
		else:
			set_texture(normal_texture)
		count += 1
		if count > 4:
			count = 1

func speech():
	if not $SpeechBalloon.is_visible():
		$SpeechBalloon.show()
		$SpeechBalloon/Animations.play("Show")
		yield($SpeechBalloon/Animations, "animation_finished")
		$SpeechBalloon/Animations.play("Idle")
		yield(get_tree().create_timer(3.0), "timeout")

func silence():
	$SpeechBalloon/Animations.play_backwards("Show")
	yield($SpeechBalloon/Animations, "animation_finished")
	$SpeechBalloon.hide()