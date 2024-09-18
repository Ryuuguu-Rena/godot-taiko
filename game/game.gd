extends Node

@export var hit_scene: PackedScene
var hits: Array
var ar: float
var acc: float
var i = 0
var current_hit


func _ready() -> void:
	hits = [
		{'type': Constants.HitType.RED, 'delay': 1},
		{'type': Constants.HitType.BLUE, 'delay': 1}, 
		{'type': Constants.HitType.BIGBLUE, 'delay': 2}, 
		{'type': Constants.HitType.BIGRED, 'delay': 1},
	]
	ar = 1
	acc = 0.1
	$StartTimer.wait_time = ar


func _process(delta: float) -> void:
	$Label.text = (str($HitStartTimer.time_left) + '\n' + str($HitEndTimer.time_left) + 
	'\n' + str(delta))


func instantiate_hit(dict_hit) -> void:
	var hit = hit_scene.instantiate()
	hit.type = dict_hit.type
	hit.position = $HitPosition.position
	var distance = $HitPosition.position.x - $CircleRate.position.x
	var velocity = distance / ar
	hit.linear_velocity = Vector2(velocity, 0).rotated(PI)
	add_child(hit)


func next_hit(delay: float) -> Constants.HitType:
	var new_hit = hits.pop_front()
	if new_hit:
		$HitEndTimer.start(delay + new_hit.delay)
		i -= 1
	else:
		$HitEndTimer.stop()
	var tree = get_tree()
	var node = tree.get_first_node_in_group('hits')
	tree.queue_delete(node)
	return node.type


func drum_press(press_type: String) -> void:
	var rest_time = $HitEndTimer.time_left
	if 0 < rest_time && rest_time <= acc * 2:
		var hit_type = next_hit(rest_time)
		var is_excellent_interval = abs(rest_time - acc) <= acc / 2
		var is_correct_press = ((press_type == 'inner' || press_type == 'double_inner') &&
			hit_type == Constants.HitType.RED ||
			(press_type == 'outer' || press_type == 'double_outer') &&
			hit_type == Constants.HitType.BLUE)
		var is_correct_double_press = (press_type == 'double_inner' &&
			hit_type == Constants.HitType.BIGRED ||
			press_type == 'double_outer' &&
			hit_type == Constants.HitType.BIGBLUE)
			
		if is_excellent_interval && (is_correct_press || is_correct_double_press):
			$CircleRate.play_animation('excellent')
			$Hud.add_points(300)
			$Label3.text += str(abs(rest_time - acc)) + 'exce\n'
		elif (!is_excellent_interval && (is_correct_press || is_correct_double_press) ||
			is_excellent_interval && !is_correct_double_press):
			$CircleRate.play_animation('good')
			$Hud.add_points(100)
			$Label3.text += str(abs(rest_time - acc)) + 'good\n'
		else:
			$CircleRate.play_animation('bad')
			$Hud.break_multiplier()
			$Label3.text += '\n'
		#добавить очки
	$Label2.text += press_type + '\n'


func _on_start_timer_timeout() -> void:
	current_hit = hits.pop_front()
	$HitStartTimer.start(current_hit.delay)
	$HitEndTimer.start(current_hit.delay + ar + acc)


func _on_hit_start_timer_timeout() -> void:
	instantiate_hit(current_hit)
	if i < hits.size():
		current_hit = hits[i]
		$HitStartTimer.start(current_hit.delay)
		i += 1
	else:
		$HitStartTimer.stop()


func _on_hit_end_timer_timeout() -> void:
	$CircleRate.play_animation('bad')
	$Hud.break_multiplier()
	next_hit(0)
