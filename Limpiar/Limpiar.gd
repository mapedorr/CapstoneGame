extends Node2D

export(PackedScene) var leaf
export(PackedScene) var stick
export(PackedScene) var flower
export(PackedScene) var mushroom
export(bool) var skip_tutorial
export(int) var goal_females = 4

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
var basic_mugre
var breakable_mugre
var females_on_trunk = 0
var game_finished = false
var in_tutorial = 1

func _ready():
	# Assign listeners
	$MasterTimer.connect("timeout", self, "_on_master_timer_timeout")
	$MusicManager.connect("music_started", self, "_on_music_started")
	$Bird4/DancingBird.connect("tutorial_explained", self, "_on_tutorial_explained")
	$Bird4/DancingBird.connect("tutorial_finished", self, "_on_tutorial_finished")
	$UI.connect("start_game", self, "start_game")
	# Start animations
	$FondoL1/AnimationPlayer.play("Idle")
	$PrimerPlano/AnimationPlayer.play("Idle")
#	$LeafContainer/Leaf.connect("object_swiped", self, "play_whoosh")
#	$LeafContainer/Mushroom.connect("object_swiped", self, "play_whoosh")
	
func _on_master_timer_timeout():
	if clean:
		clean_countdown = 0
		secs += 1
		
		if secs > 59:
			secs = 0
			mins += 1
			if mins > 59:
				mins = 0

#		if secs == 13:
#			$MasterTimer.stop()
#			game_finished = true
#			return
		
		spawn_countdown -= 1
		if spawn_countdown <= 0:
			spawning = true
	elif not spawning:
		match clean_countdown:
			0:
				yield(get_tree().create_timer(0.3), "timeout")
				$UI.show_cleanliness_check()
			5:
				$UI.show_cleanliness_check(1)
			7:
				$UI.show_cleanliness_check(2)
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
	var pos_x = randi()%(max_x - min_x) + min_x
	var pos_y = randi()%(max_y - min_y) + min_y
	create_mugre(Vector2(pos_x, pos_y))

func randomize_mugre():
	randomize()
	if randi() % 100 > 25:
		basic_mugre = leaf
	else:
		basic_mugre = stick
	randomize()
	if randi() % 100 > 25:
		breakable_mugre = flower
	else:
		breakable_mugre = mushroom

func reset_master_timer():
	for birds in $Females.get_children():
		$SFX_Away.play()
		birds.hide()
		females_on_trunk = 0
	$MusicManager.reset()
	timer_on = false
	secs = 0
	mins = 0
	clean_countdown = 0
	countdown_on = false
	$MasterTimer.stop()
	# Update the UI
	$UI.hide_cleanliness_check()

func check_dirt():
	dirt_on_ground -= 1
	if in_tutorial < 3:
		in_tutorial += 1
		$Bird4/DancingBird.stop_tutorial()
	elif dirt_on_ground == 0:
		spawn_countdown = 3
		clean = true
		
		$UI.hide_cleanliness_check()
		
		if females_on_trunk < goal_females:
			$MusicManager.add_layer()
			yield($Bird4/DancingBird.speech(), "completed")
			$SFX_Arrive.play()
			yield(get_tree().create_timer(2), "timeout")
			$Bird4/DancingBird.silence()

			$Females.get_child(females_on_trunk).show()
			females_on_trunk += 1
		else:
			$MasterTimer.stop()
			$MusicManager/Metronome/Timer.disconnect(
				"timeout",
				$Bird4/DancingBird,
				"dance"
			)
			yield(get_tree().create_timer(3), "timeout")
			$Bird4/DancingBird/Dance.play("PreBow")
			$Bird4/DancingBird/Up.play()
			randomize()
			yield(get_tree().create_timer(randi() % 6 + 1), "timeout")
			$Bird4/DancingBird/Dance.stop()
			$Bird4/DancingBird/Dance.play("Bow")
			$UI.show_david('end')
			$Bird4/DancingBird/Down.play()


func play_whoosh(obj_position):
	$SFX_Whoosh.position = obj_position
	$SFX_Whoosh.play()

func _on_music_started():
	if skip_tutorial:
		in_tutorial = 4 # Creo que esto no sirve pa' mierdas
		$Bird4/DancingBird.showing_tutorials = false

	$MusicManager/Metronome/Timer.connect(
		"timeout",
		$Bird4/DancingBird,
		"dance"
	)
	for leaf in $LeafContainer.get_children():
		$MusicManager/Metronome/Timer.connect("timeout", leaf, "move")
		leaf.connect("swipe_object_deleted", self, "check_dirt")

func _on_tutorial_explained(index):
	if index == 1:
		# The leaf is ready to be SPAWNED AND SWIPED
		if $LeafContainer.get_child_count() == 0:
			create_mugre(Vector2(620, 400), leaf)
	elif index == 2:
		# The mushroom is ready to be SPAWNED AND SWIPED
		if $LeafContainer.get_child_count() == 0:
			create_mugre(Vector2(620, 400), mushroom)
	else:
		dirt_on_ground = 1
		check_dirt()


func start_game():
	$MusicManager.start_metronome()


func create_mugre(position: Vector2, type: PackedScene = null) -> void:
	# Create a mugre and set its basic properties
	var new_mugre = null

	if not type:
		randomize_mugre()
		new_mugre = basic_mugre.instance() if (randi() % 21 > 8) else breakable_mugre.instance()
	else:
		new_mugre = type.instance()

	if new_mugre.name == "Leaf":
		# Set a random rotation
		randomize()
		new_mugre.get_node("Sprite").set_scale(Vector2(1.0, 1.0 if randi() % 100 > 50 else -1.0))

	new_mugre.set_position(position)
	new_mugre.set_scale(Vector2(2.3, 2.3))
	new_mugre.spawned = true
	new_mugre.in_game = true
	new_mugre.count = $MusicManager/Metronome.current_beat + 1
	
	# Connect listeners for mugre's signals
	$MusicManager/Metronome/Timer.connect("timeout", new_mugre, "move")
	new_mugre.connect("swipe_object_deleted", self, "check_dirt")
	new_mugre.connect("object_swiped", self, "play_whoosh")
	
	# Add the mugre to the tree
	$LeafContainer.add_child(new_mugre)
	
	# Update counters and cleanning flag
	spawn_count += 1
	dirt_on_ground += 1
	clean = false

func _on_tutorial_finished() -> void:
	$UI.show_david('start')
	yield($UI/Animations, "animation_finished")
	yield(get_tree().create_timer(5), "timeout")
	$UI.hide_david()
	# Hacer que se generen mugres y resetear el contador de mugres generados
	spawning = true
	spawn_count = 0
