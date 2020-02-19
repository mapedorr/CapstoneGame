extends Node

signal music_started

onready var tween_out = $Fade
onready var current_layer = 0

export var fadein_duration = 3
export var fadeout_duration = 8
export var transition_type = 1 # TRANS_SINE

var isPlaying = false
var fadingout = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if isPlaying == false:
		if $Metronome.current_measure == 1:
			isPlaying = true
			start_system()

func start_system():
	$MxBase.play()
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
		tween_out.connect("tween_completed", self, "stoplayers")
		fade_out(layers)
	for birds in $Birds.get_children():
			birds.awake = false
		
	current_layer = 0

func awake_bird(current_layer):
	fadingout = false
	while (true):
		if $Metronome.current_beat == 1:
			match current_layer:
				1:
					$Birds/Bird1.awake = true
					$Birds/Melody_Bird1.awake = true
					break
				2:
					$Birds/Bird2.awake = true
					$Birds/Melody_Bird2.awake = true
					break
				3:
					$Birds/Bird3.awake = true
					$Birds/Melody_Bird3.awake = true
					break
				4:
					$Birds/Bird4.awake = true
					$Birds/Melody_Bird4.awake = true
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
