extends Node

var isPlaying = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Metronome.start_metronome()
	
func _process(delta):
	if isPlaying == false:
		if $Metronome.current_measure == 1:
			$Mx.play()
			isPlaying = true

