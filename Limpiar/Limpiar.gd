extends Node2D

export(PackedScene) var leaf
var clean = false
var timer_on = false
var countdown_on = false
var secs = 0
var mins = 0
var spawn_countdown = 3
onready var dirt_on_ground = $LeafContainer.get_children().size()
onready var min_x = 32
onready var max_x = int(OS.get_screen_size().x - 32)
onready var min_y = 32
onready var max_y = int(OS.get_screen_size().y - 32)

func _ready():
	$Debug/CleanTime.set_text("00:00")
	for leaf in $LeafContainer.get_children():
		$MusicManager/Metronome/Timer.connect("timeout", leaf, "move")
		leaf.connect("swipe_object_deleted", self, "check_dirt")

func _on_CleanCheck_timeout():
	secs += 1
	if secs > 59:
		secs = 0
		mins += 1
		if mins > 59:
			mins = 0
	$Debug/CleanTime.set_text("%02d:%02d" % [mins, secs])
	if clean and secs == 10:
		$CleanCheck.stop()
		$UI/WinMessage.show()
		return
	spawn_countdown -= 1
	if spawn_countdown <= 0:
		clean = false
		var new_leaf = leaf.instance()
		var pos_x = randi()%(max_x - min_x) + min_x
		var pos_y = randi()%(max_y - min_y) + min_y
		new_leaf.set_position(Vector2(pos_x, pos_y))
		new_leaf.set_scale(Vector2(2.3, 2.3))
		$LeafContainer.add_child(new_leaf)

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
	
func check_dirt():
	dirt_on_ground -= 1
	if dirt_on_ground == 0:
		spawn_countdown = 3
		clean = true
