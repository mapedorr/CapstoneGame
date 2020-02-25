extends Control

onready var arrow = load("res://Assets/Pointers/Arrow.png")
onready var pointing_hand = load("res://Assets/Pointers/PointingHand.png")

export (PackedScene) var game_scene = null 

export (bool) var show_splash = true


func _ready():
	
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(
		pointing_hand,
		Input.CURSOR_POINTING_HAND,
		Vector2(6.0, 0.0)
		)
	
	if (show_splash):
		$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
		$AnimationPlayer.play("SplashScreen")
	else:
		get_tree().change_scene_to(game_scene)

func _on_animation_finished(anim_name):
	get_tree().change_scene_to(game_scene)


