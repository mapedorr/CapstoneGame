extends Node

onready var timer = $Timer
onready var display = $Display

export(int) var time_signature_top = 4
export(int) var time_signature_botton = 4
export(float) var  bpm  
export(bool) var quarter
export(bool) var eight


var beat_count
var beat_interval
var current_beat
var current_measure

var isPlaying

func _ready():
	isPlaying = false
	current_beat = 0
	current_measure = -1
	
	if quarter:
		bpm = bpm
		time_signature_top = time_signature_top
		time_signature_botton = time_signature_botton
	if eight:
		bpm = bpm
		time_signature_top = time_signature_top*2
		time_signature_botton = time_signature_botton*2
		
	
	
	beat_interval = 60 / bpm * 4 / float(time_signature_botton)
	timer.set_wait_time(beat_interval)
	display.set_text("0  0")



func _play_metronome():
	if not isPlaying:
		isPlaying = true
		timer.start()
	if current_beat % time_signature_top == 0:
		current_beat = 1
		current_measure += 1
		display.set_text(str(current_measure) + "  " + str(current_beat))
	else:
		current_beat += 1
		display.set_text(str(current_measure) + "  " + str(current_beat))

func _on_Timer_timeout():
	if isPlaying == true:
		_play_metronome()

func start_metronome():
	if isPlaying == false:
		_play_metronome()

func stop_metronome():
	if isPlaying == true:
		isPlaying = false
		current_beat = 0
		current_measure = -1
		display.set_text("0  0")
