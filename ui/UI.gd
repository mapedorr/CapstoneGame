extends CanvasLayer

signal start_game
signal started

onready var cleanliness_visible = false
var hearts = 3
var coco = 0

func _ready():
	# Establecer estados por defecto
	$CleanlinessCheck.hide()
	$EndScreen.hide()
	$StartScreen/StartButtons/LanguageOps/Es.pressed = true
	
	# Conectar señales
	$StartScreen/StartButtons/Start.connect("pressed", self, "_on_start_pressed")
	$StartScreen/StartButtons/Credits.connect("pressed", self, "_on_credits_pressed")
	$StartScreen/Credits/Back.connect("pressed", self, "_on_back_pressed")
	$StartScreen/AnimationPlayer.play("Show")
	$StartScreen/StartButtons/LanguageOps/Es.connect(
		'pressed', self, '_on_language_changed', ['es']
	)
	$StartScreen/StartButtons/LanguageOps/En.connect(
		'pressed', self, '_on_language_changed', ['en']
	)
	LanguageManager.connect('language_changed', self, '_on_language_changed')
	
	# ¿Reproducir sonido de animación?
	yield(get_tree().create_timer(0.3), "timeout")
	$UI_Menu_In.play()
	emit_signal('started')

func show_cleanliness_check(frame = 0):
	$CleanlinessCheck/Bird.change_frame(frame)
	if not cleanliness_visible:
		$Show.play()
		cleanliness_visible = true
		$CleanlinessCheck.show()
		$CleanlinessCheck.propagate_call("play_animation")
		$Animations.play("ShowCleanlinessCheck")
	else:
		get_node("CleanlinessCheck/Heart%d" % (4 - frame)).play_animation("Break")
		match hearts:
			3:
				$Heart.play()
				hearts -= 1
			2:
				$Heart2.play()
				hearts -= 1
			1:
				$Heart3.play()
				hearts -= 1

func hide_cleanliness_check():
	if cleanliness_visible:
		hearts = 3
		$Hide.play()
		$Animations.play_backwards("ShowCleanlinessCheck")
		yield($Animations, "animation_finished")
		$CleanlinessCheck.propagate_call("stop_animation")
		cleanliness_visible = false
		$CleanlinessCheck.hide()

func _on_start_pressed():
	$StartScreen/AnimationPlayer.play_backwards("Show")
	$UI_Menu_Out.play()
	yield($StartScreen/AnimationPlayer, "animation_finished")
	$StartScreen.hide()
	emit_signal("start_game")

func _on_credits_pressed():
	$StartScreen/AnimationPlayer.play("ShowCredits", -1, 1.5)
	$UI_Menu_Click.play()

func _on_back_pressed():
	$StartScreen/AnimationPlayer.play_backwards("ShowCredits")
	$UI_Menu_Back.play()

func show_david(status):
	$UI_David_In.play()
	if status == 'start':
		$David/Globo/Label.set_text('TIME_TO_CLEAN')
	else:
		$David/Globo/Label.set_text('TIME_TO_DANCE')
	$Animations.play("ShowDavid")

func hide_david():
	$UI_David_Out.play()
	$Animations.play_backwards("ShowDavid")

func show_end():
	$EndScreen.show()
	$EndScreen/ToMainMenuSFX.play()
	$EndScreen/AnimationPlayer.play("ShowButton")
	yield($EndScreen/AnimationPlayer, "animation_finished")
	$EndScreen/AnimationPlayer.play("IdleButton")
	$EndScreen/ToMainMenu.connect("pressed", self, "_on_to_main_menu_pressed")

func _on_to_main_menu_pressed():
	var master_volume_db = AudioServer.get_bus_volume_db(0)
	$EndScreen/Tween.interpolate_method(self, "change_master_volume", master_volume_db, -24, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$EndScreen/Tween.start()
	$EndScreen/AnimationPlayer.stop()
	$EndScreen/AnimationPlayer.play("HideButton")
	yield($EndScreen/Tween, 'tween_completed')
	get_tree().reload_current_scene()

func change_master_volume(new_val):
	AudioServer.set_bus_volume_db(0, new_val)

func _on_language_changed(language: String):
	TranslationServer.set_locale(language)

	match language:
		'es':
			$StartScreen/StartButtons/LanguageOps/Es.pressed = true
			$StartScreen/StartButtons/LanguageOps/En.pressed = false
			$StartScreen/GameName.set_texture($StartScreen/GameNameEs.texture)
		'en':
			$StartScreen/StartButtons/LanguageOps/Es.pressed = false
			$StartScreen/StartButtons/LanguageOps/En.pressed = true
			$StartScreen/GameName.set_texture($StartScreen/GameNameEn.texture)
