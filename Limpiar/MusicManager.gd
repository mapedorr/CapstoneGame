extends Node

signal music_started

onready var tween_out = $Fade
onready var current_layer = 0

export var fadein_duration = 3
export var fadeout_duration = 8
export var transition_type = 1 # TRANS_SINE

var isPlaying = false
var fadingout = false
var music_played = false
var david_shown = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if isPlaying  == false:
		if $Metronome.current_measure == 1:
			isPlaying = true
			start_system()
	else:
		if not music_played and david_shown and $Metronome.current_beat == 1:
			music_played = true
			for birds in $Birds.get_children():
				birds.awake = true
			$MxBase.play()

func start_system():
	emit_signal("music_started")
	
func add_layer():
	current_layer += 1
	awake_bird(current_layer)
	while (true):
		if $Metronome.current_beat == 1:
			match current_layer:
				1:
					break
				2:
					$Layers/Layer1.play($MxBase.get_playback_position())
					fade_in($Layers/Layer1, 3, 6)
					break
				3:
					$Layers/Layer2.play($MxBase.get_playback_position())
					fade_in($Layers/Layer2, 3, 6)
					break
				4:
					break
		yield(get_tree().create_timer(0.3),"timeout")

func reset():
	for layers in $Layers.get_children():
		if not tween_out.is_connected("tween_completed", self, "stoplayers"):
			tween_out.connect("tween_completed", self, "stoplayers")
		fade_out(layers)
	for birds in $Birds.get_children():
			birds.sleep()
		
	current_layer = 0

func awake_bird(current_layer):
	fadingout = false
	while (true):
		if $Metronome.current_beat == 1:
			match current_layer:
				1:
					$Birds/Melody_Bird1.awake()
					break
				2:
					$Birds/Melody_Bird2.awake()
					break
				3:
					$Birds/Melody_Bird3.awake()
					break
				4:
					$Birds/Melody_Bird4.awake()
					break
		yield(get_tree().create_timer(0.3),"timeout")

func stoplayers(object, key):
	if fadingout:
		for layers in $Layers.get_children():
			layers.stop()

func fade_in(music_to_fade, fadein_duration, end_volume = 0):
	tween_out.interpolate_property(music_to_fade, "volume_db", music_to_fade.volume_db, end_volume, fadein_duration, transition_type, Tween.EASE_OUT, 1)
	tween_out.start()

func fade_out(music_to_fade):
	fadingout = true
	tween_out.interpolate_property(music_to_fade, "volume_db", music_to_fade.volume_db, -80, fadeout_duration, transition_type, Tween.EASE_OUT, 1)
	tween_out.start()

func start_metronome():
	$Metronome.start_metronome()
