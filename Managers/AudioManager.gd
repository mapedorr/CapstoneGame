extends Node2D


func _ready():
	EventManager.connect("play_requested", self, "_on_play_requested")
	
	
func _on_play_requested(source, sound, _position):
	get_node("" + source + "/" + sound).set_position(_position)
	get_node("" + source + "/" + sound).play()
