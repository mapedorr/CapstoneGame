extends Node2D

signal swipe_object_deleted

onready var _swipe_directions = $SwipeDetector.Directions

export(int) var cuando = 1
export(bool) var random_movement
export(int) var max_count = 8

var count = 2
var spawned = false
var in_game = false

func _ready():
	# Connect signals
	$SwipeDetector.connect("swipe_started", self, "_on_swipe_started")
	$SwipeDetector.connect("swipe_ended", self, "_on_swipe_ended")
	$SwipeDetector.connect("swipe_failed", self, "_on_swipe_failed")
	$SwipeDetector.connect("swiped", self, "_on_swiped")
	$Tween.connect("tween_completed", self, "self_destroy")

	if random_movement:
		randomize()
		cuando = randi() % max_count + 1

func _enter_tree():
	if self.has_node("SFX_Spawn") and spawned:
		$SFX_Spawn.play()
	$SwipeDetector/Area2D.transform = transform

func _on_swipe_started(partial_gesture):
	if in_game:
		$SwipeDetector/Area2D/CollisionShape2D.set_scale(Vector2 (10, 10))

func _on_swipe_ended(partial_gesture):
	if in_game:
		$SwipeDetector/Area2D/CollisionShape2D.set_scale(Vector2 (1, 1))

func _on_swipe_failed():
	if in_game:
		$SwipeDetector/Area2D/CollisionShape2D.set_scale(Vector2 (1, 1))

func _on_swiped(gesture):
	if not in_game: return
	
	self.in_game = false
	$Sprite/Dance.stop()
	
	emit_signal("swipe_object_deleted")
	
	var target = self.get_position()
	match gesture.get_direction():
		_swipe_directions.DIRECTION_LEFT:
			target.x = -get_viewport_rect().size.x
		_swipe_directions.DIRECTION_UP:
			target.y = -get_viewport_rect().size.y
		_swipe_directions.DIRECTION_DOWN:
			target.y = get_viewport_rect().size.y + 200.0
		_swipe_directions.DIRECTION_RIGHT:
			target.x = get_viewport_rect().size.x + 200.0
	
	$SwipeDetector.queue_free()
	$Tween.interpolate_property(
		self,
		"position",
		self.get_position(),
		target,
		1.0,
		$Tween.TRANS_SINE,
		$Tween.EASE_OUT
	)
	$Tween.start()

func move():
	if not in_game: return
	
	if cuando == count:
		$Sprite/Dance.play("Dance")
	count += 1
	if count > max_count:
		count = 1

func self_destroy(obj, key):
	queue_free()