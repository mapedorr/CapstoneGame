extends Node2D

export (int) var bar_per_sound = 4
export (int) var weight = 100
export (float) var inst_vol = 0

var index_sound = -1
var select_sound
var bar_count = 1
var can_play = true
var awake = false
onready var init_vol = inst_vol

func _ready():
	randomize()
	index_sound = randi()%get_child_count()
	select_sound = get_child(index_sound)
	inst_vol = -80
	select_sound.set_volume_db(inst_vol)

func _on_upbeat_ticked(current_bar):
	bar_count += 1
	if awake:
		if bar_count == 1:
			playsound()
	if bar_count == bar_per_sound:
		can_play = true
		bar_count = 0


func playsound():
	randomize()
	var randomNumber = randi()%100
	if randomNumber < weight:
		select_sound.play()
		index_sound = randi()%get_child_count()
		select_sound = get_child(index_sound)
		select_sound.set_volume_db(inst_vol)

func awake():
	get_node('../../Fade').interpolate_method(
		self,
		"change_volume",
		-80,
		init_vol,
		2,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	get_node('../../Fade').start()
	
func sleep():
	get_node('../../Fade').interpolate_method(
		self,
		"change_volume",
		init_vol,
		-80,
		1,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	get_node('../../Fade').start()

func change_volume(new_val: float):
	inst_vol = new_val
	select_sound.set_volume_db(new_val)
