extends Node2D

var clean = false
var timer_on = false
var countdown_on = false
var secs = 0
var mins = 0

func _ready():
	$Debug/CleanTime.set_text("00:00")
	$SwipeObject.connect("object_pressed", self, "start_clean_check")

func _on_CleanCheck_timeout():
	secs += 1
	if secs > 59:
		secs = 0
		mins += 1
		if mins > 59:
			mins = 0
	$Debug/CleanTime.set_text("%02d:%02d" % [mins, secs])

func start_clean_check():
	clean = !clean
	
func _process(delta):
	if clean:
		if not timer_on:
			timer_on = true
			$CleanCheck.start()
		else:
			$CleanCheck.set_paused(false)
	elif timer_on and not countdown_on:
		countdown_on = true
		$CleanCheck.set_paused(true)
		$ResetCountdown.start()

func _on_ResetCountdown_timeout():
	# reset the CleanCheck
	reset_clean_check()
	countdown_on = false
	$CleanCheck.stop()
	$Debug/CleanTime.set_text("00:00")
	
func reset_clean_check():
	timer_on = false
	secs = 0
	mins = 0
