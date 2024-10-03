extends Node

@export var hit_scene: PackedScene
var hits: Array
var ar: float
var acc: float
var i = 0
var current_hit
var external_dir
var scene_tree

func _ready() -> void:
	#hits = [
		#{'type': Constants.HitType.RED, 'delay': 1},
		#{'type': Constants.HitType.BLUE, 'delay': 1}, 
		#{'type': Constants.HitType.BIGBLUE, 'delay': 2}, 
		#{'type': Constants.HitType.BIGRED, 'delay': 1},
	#]
	scene_tree = get_tree()
	var os_name = OS.get_name()
	if os_name == 'Android':
		external_dir = DirAccess.open('/storage/emulated/0')
		if !external_dir.dir_exists('taikogame'):
			external_dir.make_dir('taikogame')
		external_dir = '/storage/emulated/0/taikogame'
	elif os_name == 'Linux':
		external_dir = 'res://resource/map'
	#OS.alert(str(DirAccess.dir_exists_absolute('/storage')))
	#OS.alert(str(DirAccess.dir_exists_absolute('/storage/emulated')))
	#OS.alert(str(DirAccess.dir_exists_absolute('/storage/emulated/0')))
	
	#OS.alert(OS.get_user_data_dir())
	#DirAccess.dir_exists_absolute('/storage/emulated/0')
	#var dirs = DirAccess.get_directories_at('/storage/emulated/0/Download')
	
	#var emul = DirAccess.open('/storage/emulated/0')
	#var perm = OS.get_granted_permissions()
	#var output = external_dir + '/map1.zip: ' + str(FileAccess.file_exists(external_dir + '/map1.zip')) + '\n'
	#output += 'perm: ' + ' '.join(perm) + '\n'
	#OS.alert(output)
	#OS.alert(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
	#OS.alert(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP, false))
	#OS.alert(OS.get_user_data_dir())
	
	
	load_map(external_dir + '/map1.zip')
	ar = 2
	acc = 0.5


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


#func next_hit(delay: float) -> Constants.HitType:
func next_hit() -> Constants.HitType:
	var new_hit = hits.pop_front()
	var delay = $HitEndTimer.time_left
	if new_hit:
		var res_delay = delay + new_hit.delay
		#var res_delay = new_hit.delay
		$ItemList.add_item(str(delay) + ' ' + str(res_delay)) 
		$HitEndTimer.start(res_delay)
		i -= 1
	else:
		OS.alert('stop')
		$HitEndTimer.stop()
	var node = scene_tree.get_first_node_in_group('hits')
	scene_tree.queue_delete(node)
	return node.type


func load_map(file_name: String) -> void:
	var reader = ZIPReader.new()
	var err = reader.open(file_name)
	if err != OK:
		OS.alert('Ошибка чтения архива')
	var map = reader.read_file('map1.map').get_string_from_ascii()
	hits = JSON.parse_string(map)
	var map_music = AudioStreamMP3.new()
	map_music.data = reader.read_file('map1.mp3')
	$MapMusic.stream = map_music
	reader.close()


func drum_press(press_type: String) -> void:
	var rest_time = $HitEndTimer.time_left
	if 0 < rest_time && rest_time <= acc * 2:
		#var dbg_hit = press_type +  ' ' + str(rest_time)
		var hit_type = next_hit()
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
		#$ItemList.add_item(dbg_hit)


func _on_start_timer_timeout() -> void:
	current_hit = hits.pop_front()
	$HitStartTimer.start(current_hit.delay)
	$HitEndTimer.start(current_hit.delay + ar + acc)
	$MusicTimer.start(current_hit.delay + ar)


func _on_music_timer_timeout() -> void:
	$MapMusic.play()


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
	next_hit()
