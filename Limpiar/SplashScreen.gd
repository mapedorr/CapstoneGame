extends Control

export (PackedScene) var game_scene = null 

export (bool) var show_splash = true


func _ready():
	
	if (show_splash):
		$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
		$AnimationPlayer.play("SplashScreen")
	else:
		get_tree().change_scene_to(game_scene)

func _on_animation_finished(anim_name):
	get_tree().change_scene_to(game_scene)


