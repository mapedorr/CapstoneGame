extends Node2D

export(PackedScene) var leaf
export(PackedScene) var stick
export(PackedScene) var flower
onready var dirt_on_ground = $LeafContainer.get_children().size()
onready var min_x = int ($SpawnArea.position.x - $SpawnArea/CollisionShape2D.shape.extents.x)
onready var max_x = int($SpawnArea/CollisionShape2D.shape.extents.x*2)
onready var min_y = int ($SpawnArea.position.y - $SpawnArea/CollisionShape2D.shape.extents.y)
onready var max_y = int($SpawnArea/CollisionShape2D.shape.extents.y*2)
var clean = false
var timer_on = false
var countdown_on = false
var secs = 0
var mins = 0
var spawn_countdown = 3
var spawning = false
var spawn_timer = 0
var spawn_count = 0
var spawn_limit = 4
var clean_countdown = 0

func _ready():
	$MasterTimer.connect("timeout", self, "_on_master_timer_timeout")
	$Debug/CleanTime.set_text("00:00")
	for leaf in $LeafContainer.get_children():
		$MusicManager/Metronome/Timer.connect("timeout", leaf, "move")
		leaf.connect("swipe_object_deleted", self, "check_dirt")

func _on_master_timer_timeout():
	if clean:
		clean_countdown = 0
		secs += 1
		if secs > 59:
			secs = 0
			mins += 1
			if mins > 59:
				mins = 0
		# TODO: update the UI
		$Debug/CleanTime.set_text("%02d:%02d" % [mins, secs])

		if secs == 10:
			$MasterTimer.stop()
			$UI/WinMessage.show()
			return
		
		spawn_countdown -= 1
		if spawn_countdown <= 0:
			spawning = true
	else:
		clean_countdown += 1
		if clean_countdown == 10:
			reset_master_timer()

func start_clean_check():
	clean = !clean

func _process(delta):
	if clean:
		if not timer_on:
			timer_on = true
			$MasterTimer.start()
		else:
			countdown_on = false
	elif timer_on and not countdown_on:
		countdown_on = true

func _physics_process(delta):
	if spawning:
		spawn_timer += 1
		if spawn_timer == 30:
			spawn_mugre()
			spawn_timer = 0
		if spawn_count == spawn_limit:
			spawning = false
			spawn_count = 0
			spawn_limit += 2

func spawn_mugre():
	var new_mugre = leaf.instance() if (randi() % 21 > 10) else flower.instance()
	var pos_x = randi()%(max_x - min_x) + min_x
	var pos_y = randi()%(max_y - min_y) + min_y
	new_mugre.set_position(Vector2(pos_x, pos_y))
	new_mugre.set_scale(Vector2(2.3, 2.3))
	$MusicManager/Metronome/Timer.connect("timeout", new_mugre, "move")
	new_mugre.connect("swipe_object_deleted", self, "check_dirt")
	$LeafContainer.add_child(new_mugre)
	spawn_count += 1
	dirt_on_ground += 1
	clean = false

func reset_master_timer():
	timer_on = false
	secs = 0
	mins = 0
	clean_countdown = 0
	countdown_on = false
	$MasterTimer.stop()
	$Debug/CleanTime.set_text("00:00")
	
func check_dirt():
	dirt_on_ground -= 1
	if dirt_on_ground == 0:
		$MusicManager.add_layer()
		spawn_countdown = 3
		clean = true
