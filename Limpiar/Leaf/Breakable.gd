extends "res://Limpiar/Leaf/SwipeObject.gd"

var alive = true
var cuando2 = 2
var hp = 2

func _ready():
	if random_movement:
		randomize()
		cuando2 = randi() % max_count + 1
	$TouchScreenButton.connect("pressed", self, "kill")

func _on_swiped(gesture):
	if not alive:
		._on_swiped(gesture)

func move():
	if hp > 1:
		.move()
		if cuando2 == count:
			$Sprite/Dance.play("Dance")
			randomize()
			cuando2 = randi() % max_count + 1

func kill():
	if alive:
		hp -= 1
		if hp == 1:
			$Sprite/Dance.play("Dead")
		if hp == 0:
			alive = false