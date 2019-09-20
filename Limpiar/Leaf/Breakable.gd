extends "res://Limpiar/Leaf/SwipeObject.gd"

var alive = true
var cuando2 = 2
var hp = 2
var kill_called = false

func _ready():
	cuando2 = cuando
	if random_movement:
		randomize()
		cuando2 = randi() % max_count + 1

func _on_swipe_started(partial_gesture):
	._on_swipe_started(partial_gesture)
	if alive:
		kill()

func _on_swiped(gesture):
	if not alive:
		._on_swiped(gesture)

func _on_swipe_ended(partial_gesture):
	._on_swipe_ended(partial_gesture)
	if alive:
		kill()

func move():
	if hp > 1:
		.move()
		if cuando2 == count:
			$Sprite/Animator.play("Dance")
			randomize()
			cuando2 = randi() % max_count + 1

func kill():
	hp -= 1
	if hp == 1:
		$Sprite/Animator.play("Dead")
		$SFX_Death.play()
	elif hp <= 0:
		alive = false