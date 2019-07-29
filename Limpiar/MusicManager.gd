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
	$Metronome.start_metronome()
	
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
					fade_in($Layers/Layer1, 3)
					break
				3:
					$Layers/Layer2.play($MxBase.get_playback_position())
					fade_in($Layers/Layer2, 3)
					break
				4:
					break
		yield(get_tree().create_timer(0.3),"timeout")

func reset():
	for layers in $Layers.get_children():
		tween_out.connect("tween_completed", self, "stoplayers")
		fade_out(layers)
	for birds in $Birds.get_children():
		tween_out.connect("tween_completed", self, "stoplayers")
		fade_out(birds)
		
	current_layer = 0

func awake_bird(current_layer):
	fadingout = false
	while (true):
		if $Metronome.current_beat == 1:
			match current_layer:
				1:
					$Birds/Birds1.play($MxBase.get_playback_position())
					fade_in($Birds/Birds1, 1)
					break
				2:
					$Birds/Birds2.play($MxBase.get_playback_position())
					fade_in($Birds/Birds2, 1)
					break
				3:
					$Birds/Birds3.play($MxBase.get_playback_position())
					fade_in($Birds/Birds3, 1)
					break
				4:
					$Birds/Birds4.play($MxBase.get_playback_position())
					fade_in($Birds/Birds4, 1)
					break
		yield(get_tree().create_timer(0.3),"timeout")

func stoplayers(object, key):
	if fadingout:
		for layers in $Layers.get_children():
			layers.stop()
		for birds in $Birds.get_children():
			birds.stop()
		



func fade_in(music_to_fade, fadein_duration):
	tween_out.interpolate_property(music_to_fade, "volume_db", music_to_fade.volume_db, 0, fadein_duration, transition_type, Tween.EASE_OUT, 1)
	tween_out.start()

func fade_out(music_to_fade):
	fadingout = true
	tween_out.interpolate_property(music_to_fade, "volume_db", music_to_fade.volume_db, -80, fadeout_duration, transition_type, Tween.EASE_OUT, 1)
	tween_out.start()