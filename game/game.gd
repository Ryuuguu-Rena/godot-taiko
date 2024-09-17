extends Node

@export var hit_scene: PackedScene
var times: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	times = [0.1, 0.1, 0.1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func instantiate_hit():
	var hit = hit_scene.instantiate()
	hit.position = $HitPosition.position
	hit.linear_velocity = Vector2(150, 0).rotated(PI)
	add_child(hit)


func _on_start_timer_timeout() -> void:
	instantiate_hit()
	$HitTimer.wait_time = times.pop_front()
	$HitTimer.start()


func _on_hit_timer_timeout() -> void:
	instantiate_hit()
	var new_time = times.pop_front()
	if new_time:
		$HitTimer.wait_time = new_time
	else:
		$HitTimer.stop()
