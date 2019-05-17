extends TouchScreenButton

export(int) var cuando = 1
var face = -1.0
var count = 2
onready var normal_texture = get_texture()

func _ready():
	$"../../MusicManager/Metronome/Timer".connect("timeout", self, "dance")

func dance():
	if cuando == count:
		$Dance.play("Dance")
		set_scale(Vector2(get_scale().x * face, get_scale().y))
		$Chirp.play()
		set_texture(pressed)
	else:
		set_texture(normal_texture)
	count += 1
	if count > 4:
		count = 1