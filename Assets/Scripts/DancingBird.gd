extends Sprite
""" ════ Señales ═══════════════════════════════════════════════════════════ """
signal tutorial_explained(index)
signal tutorial_finished
signal middle_reached
""" ════ Variables ═════════════════════════════════════════════════════════ """
export(int) var cuando = 1
var face = -1.0
var count = 2
var pre_count = 0
var moving = false
var points = 2
var destination = 1
var tutorial_steps = [
	[
		[0, 1, 2],
		[3, 4, 5],
		[6, 7, 8, 9, 10, 11]
	],
	[
		[0, 1, 2, 1],
		[3, 4, 5, 4],
		[6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	]
]
var current_tutorial = null
var current_tutorial_index = 0
var tutorial_index = 0
var step_index = 0
var tutorial_repeat = 0
onready var default_position = get_parent().get_position()
onready var normal_texture = get_texture()
var tutorial_dance_count = 0
var showing_tutorials = true


""" ════ Funciones ═════════════════════════════════════════════════════════ """
func _ready():
	$SpeechBalloon.hide()
	$SpeechBalloon/Timer.connect("timeout", self, "_on_tutorial_timeout")

func dance():
	pre_count += 1
	if pre_count == 2:
		pre_count = 0
		if cuando == count:
			if not moving:
				var scream = false
				if $SpeechBalloon.is_visible():
					$Dance.play("Speak")
				else:
					$Dance.play("Dance")
					
					if showing_tutorials:
						tutorial_dance_count += 1
						if tutorial_dance_count == 2:
							# Set the texture and frames number for the first tutorial
							# (a.k.a. the normal object)
							$SpeechBalloon/Tutorial.set_texture($SpeechBalloon/Tutorial.tutorial_a)
							$SpeechBalloon/Tutorial.set_hframes($SpeechBalloon/Tutorial.tutorial_a_frames)
							# Start the tutorial animation
							begin_tutorial()
						elif tutorial_dance_count == 3:
							scream = true
						elif tutorial_dance_count == 4:
							# Set the texture and frames number for the second tutorial
							# (a.k.a. the swipeable object)
							$SpeechBalloon/Tutorial.set_texture($SpeechBalloon/Tutorial.tutorial_b)
							$SpeechBalloon/Tutorial.set_hframes($SpeechBalloon/Tutorial.tutorial_b_frames)
							# Start the tutorial animation
							begin_tutorial()
					else:
						tutorial_dance_count += 1
						if tutorial_dance_count == 1:
							scream = true
						elif tutorial_dance_count == 2:
							emit_signal("tutorial_finished")
				if scream:
					$Scream.play()
				else:
					$Chirp.play()
			else:
				if go_to_mugres(destination):
					$Call.play()
		else:
			set_texture(normal_texture)
		count += 1
		if count > 4:
			count = 1


func go_to_mugres(movimiento):
	match movimiento:
		1:
			if moving:
				match points:
					3:
						move($Waypoints/A.position)
						points -= 1
					2:
						move($Waypoints/B.position)
						points -= 1
					1:
						move($Waypoints/C.position)
						points -= 1
					0:
						moving = false
						destination = 2
						points = 2
						# Set the texture and frames number for the first tutorial
						# (a.k.a. the normal object)
						$SpeechBalloon/Tutorial.set_texture($SpeechBalloon/Tutorial.tutorial_a)
						$SpeechBalloon/Tutorial.set_hframes($SpeechBalloon/Tutorial.tutorial_a_frames)
						# Start the tutorial animation
						begin_tutorial()
		2:
			if moving:
				match points:
					2:
						move($Waypoints/D.position)
						points -= 1
					1:
						move($Waypoints/E.position)
						points -= 1
					0:
						moving = false
						destination = 3
						points = 4
						# Set the texture and frames number for the second tutorial
						# (a.k.a. the swipeable object)
						$SpeechBalloon/Tutorial.set_texture($SpeechBalloon/Tutorial.tutorial_b)
						$SpeechBalloon/Tutorial.set_hframes($SpeechBalloon/Tutorial.tutorial_b_frames)
						# Start the tutorial animation
						begin_tutorial()
		3:
			if moving:
				match points:
					4:
						move($Waypoints/D.position)
						points -= 1
					3:
						move($Waypoints/C.position)
						points -= 1
					2:
						move($Waypoints/B.position)
						points -= 1
					1:
						move(default_position)
						points -= 1
						moving = false
					0:
						$SpeechBalloon.hide()
						emit_signal("tutorial_explained", current_tutorial_index + 1)
		4:
			# Ir al centro y luego hacer la reverencia
			match points:
				3:
					move($Waypoints/A.position)
					points -= 1
				2:
					move($Waypoints/B.position)
					points -= 1
				1:
					move($Waypoints/C.position)
					points -= 1
				0:
					moving = false
					emit_signal("middle_reached")
					return false
	return true

func begin_tutorial():
	$Dance.play("Speak")
	current_tutorial = tutorial_steps[current_tutorial_index]
	$SpeechBalloon/Tutorial.set_frame(current_tutorial[tutorial_index][step_index])
	yield(show_balloon(), "completed")
	$SpeechBalloon/Tutorial.show()
	$SpeechBalloon/Timer.start()

func speech():
	if not $SpeechBalloon.is_visible():
		$Dance.play("Speak")
		$Speech_Op.play()
		$SpeechBalloon.show()
		$SpeechBalloon/Animations.play("Show")
		$Scream.play()
		yield($SpeechBalloon/Animations, "animation_finished")
		$SpeechBalloon/Animations.play("Idle")
		yield(get_tree().create_timer(1.3), "timeout")

func silence():
	$Speech_Cl.play()
	$SpeechBalloon/Animations.play_backwards("Show")
	yield($SpeechBalloon/Animations, "animation_finished")
	$SpeechBalloon.hide()

func move(waypoint):
	$Dance.play("Dance")
	$Jump.play()
	get_parent().position = waypoint

func show_balloon():
	if not $SpeechBalloon.is_visible():
		$Speech_Op.play()
		$SpeechBalloon.show()
		$SpeechBalloon/Animations.play("ShowNoText")
		yield($SpeechBalloon/Animations, "animation_finished")
		$SpeechBalloon/Animations.play("Idle")
	else:
		$Speech_Cl.play()
		$SpeechBalloon/Animations.play_backwards("ShowNoText")
		yield($SpeechBalloon/Animations, "animation_finished")
		$SpeechBalloon.hide()

func _on_tutorial_timeout():
	step_index += 1
	if step_index >= current_tutorial[tutorial_index].size():
		step_index = 0
		tutorial_repeat += 1
	if tutorial_repeat == 2:
		tutorial_repeat = 0
		tutorial_index += 1
	if tutorial_index >= current_tutorial.size():
		tutorial_index = 0
		emit_signal("tutorial_explained", current_tutorial_index + 1)
	$SpeechBalloon/Tutorial.set_frame(current_tutorial[tutorial_index][step_index])

func stop_tutorial():
	$SpeechBalloon/Timer.stop()
	step_index = 0
	tutorial_repeat = 0
	tutorial_index = 0
	current_tutorial_index += 1
	$SpeechBalloon/Tutorial.set_texture($SpeechBalloon/Tutorial.tutorial_a)
	$SpeechBalloon/Tutorial.set_hframes($SpeechBalloon/Tutorial.tutorial_a_frames)
	$SpeechBalloon/Tutorials.play("WellDone")
	yield($SpeechBalloon/Tutorials, "animation_finished")
	$SpeechBalloon/Tutorial.hide()
	yield(show_balloon(), "completed")
	if current_tutorial_index == 2:
		showing_tutorials = false
		tutorial_dance_count = 0

func go_to_middle():
	moving = true
	destination = 4
	points = 3
