extends Node


onready var current_layer = 0

var isPlaying = false

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
	
func add_layer():
	current_layer += 1
	
	while (true):
		if $Metronome.current_beat == 1:
			match current_layer:
				1:
					$Layer1.play($MxBase.get_playback_position())
					break
				2:
					$Layer2.play($MxBase.get_playback_position())
					break
				3:
					$Layer3.play($MxBase.get_playback_position())
					break
		yield(get_tree().create_timer(0.3),"timeout")