extends TextureRect

onready var max_frames = (texture.get_atlas().get_width() / self.texture.get_width()) - 1.0
var current_frame = 0

func change_frame(frame = 0):
	if frame > max_frames:
		frame = 0
	if frame < 0:
		frame = max_frames
	current_frame = frame
	self.texture.set_region(Rect2(
		Vector2(self.texture.get_width() * current_frame, 0),
		self.texture.get_size())
	)
	self.update()

func next_frame():
	change_frame(current_frame + 1)
	
func prev_frame():
	change_frame(current_frame - 1)

func play_animation(name = "Idle"):
	if self.has_node("Animations"):
		$Animations.play(name)

func stop_animation():
	if self.has_node("Animations"):
		$Animations.stop(true)
		$Animations.seek(0.0, true)