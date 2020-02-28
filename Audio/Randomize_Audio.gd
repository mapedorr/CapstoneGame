extends AudioStreamPlayer2D

var Pitch = 0
var Volume = 0

export (bool) var RandomVolume

export (float) var minVolume = 0
export (float) var maxVolume = 0


export (bool) var RandomPitch

export (float) var minPitch = 0
export (float) var maxPitch = 0

func _ready():
	Pitch =  Pitch/24
	minPitch = minPitch/24
	maxPitch = maxPitch/24
	Volume = volume_db
	set_volume_db(Volume)
	set_pitch_scale(Pitch+1)


func play(from_position = 0.0):
	randomize()
	if RandomVolume == true:
		randomizeVol(Volume, minVolume, maxVolume)
	if RandomPitch == true:
		randomizePitch(Pitch, minPitch, maxPitch)
	.play()


func randomizeVol(Volume, minVolume, maxVolume):
	var ranVol = (rand_range( minVolume, (maxVolume+1)))
	set_volume_db(Volume + ranVol)


func randomizePitch(_Pitch, minPitch, maxPitch):
		var ranPitch = (rand_range( minPitch + 1, (maxPitch+1)))
		if (_Pitch + ranPitch > 0):
			set_pitch_scale(_Pitch + ranPitch)
