extends Node

signal music_started


export var fadein_duration = 3
export var fadeout_duration = 8
export var transition_type = 1 # TRANS_SINE

onready var tween_out = $Fade
onready var current_layer = 0

const COMPENSATE_FRAMES = 2
const COMPENSATE_HZ = 60.0

var isPlaying = false
var fadingout = false
var music_played = false
var david_shown = false

# Cosas para tener las pájaras coordinadas con la música ----
var time_begin
var time_delay
var beat: int = 1
var last_tick: int = -1
var first_time = true
# ----


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if $MxBase.playing:
		var time = 0.0

		# ──────────────────────────────────────┤ SYNC_SOURCE_SYSTEM_CLOCK ├────
		# Obtain from ticks.
		time = (OS.get_ticks_usec() - time_begin) / 1000000.0
		# Compensate.
		time -= time_delay
		# ──────────────────────────────────────────────────────────────────────

		# ───────────────────────────────────────┤ SYNC_SOURCE_SOUND_CLOCK ├────
		# time = $MxBase$MxBase.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES
		# ──────────────────────────────────────────────────────────────────────

		var tick = int(abs(time * $Metronome.bpm / 60.0))
		if tick != last_tick:
			last_tick = tick

			$Birds/Melody_Bird1._on_upbeat_ticked(beat)
			$Birds/Melody_Bird2._on_upbeat_ticked(beat)
			$Birds/Melody_Bird3._on_upbeat_ticked(beat)
			$Birds/Melody_Bird4._on_upbeat_ticked(beat)

			beat += 1
			if beat == 5:
				beat = 1
		if $MxBase.get_playback_position() >= 1.0:
			first_time = false
		elif not first_time && $MxBase.get_playback_position() < 1.0:
			_on_music_started()


	if isPlaying  == false:
		if $Metronome.current_measure == 1:
			isPlaying = true
			start_system()
	else:
		if not music_played and david_shown and $Metronome.current_beat == 1:
			music_played = true

			for birds in $Birds.get_children():
				birds.awake = true

			_on_music_started()
			$MxBase.play()

func start_system():
	emit_signal("music_started")
	
func add_layer():
	current_layer += 1
	awake_bird(current_layer)
	match current_layer:
		2:
			$Layers/Layer1.play($MxBase.get_playback_position())
			fade_in($Layers/Layer1, 3, 6)
		3:
			$Layers/Layer2.play($MxBase.get_playback_position())
			fade_in($Layers/Layer2, 3, 6)
			
func reset():
	for layers in $Layers.get_children():
		if not tween_out.is_connected("tween_completed", self, "stoplayers"):
			tween_out.connect("tween_completed", self, "stoplayers")
		fade_out(layers)

	$Birds/Melody_Bird1.sleep()
	$Birds/Melody_Bird2.sleep()
	$Birds/Melody_Bird3.sleep()
	$Birds/Melody_Bird4.sleep()

	current_layer = 0

func awake_bird(current_layer):
	fadingout = false
	match current_layer:
		1:
			$Birds/Melody_Bird1.awake()
		2:
			$Birds/Melody_Bird2.awake()
		3:
			$Birds/Melody_Bird3.awake()
		4:
			$Birds/Melody_Bird4.awake()

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

func _on_music_started():
	first_time = true
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	last_tick = -1 
	beat = 1
	$Birds/Melody_Bird1.bar_count = 0
	$Birds/Melody_Bird2.bar_count = 0
	$Birds/Melody_Bird3.bar_count = 0
	$Birds/Melody_Bird4.bar_count = 0
