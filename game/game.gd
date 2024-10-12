extends Node

@export var hit_scene: PackedScene
var hits: Array
var ar: float
var acc: float
var map_max_combo = 0
var i = 0
var next_hit_type: Constants.HitType
var external_dir
var scene_tree
var start_timer
var end_timer


func _ready() -> void:
	scene_tree = get_tree()
	var os_name = OS.get_name()
	if os_name == 'Android':
		external_dir = DirAccess.open('/storage/emulated/0')
		if !external_dir.dir_exists('taikogame'):
			external_dir.make_dir('taikogame')
		external_dir = '/storage/emulated/0/taikogame'
	elif os_name == 'Linux' || os_name == 'Windows':
		external_dir = 'res://resource/map'
	
	#OS.alert(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP))
	#OS.alert(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP, false))
	#OS.alert(OS.get_user_data_dir())
	
	
	ar = 2
	acc = 0.2
	load_map(external_dir + '/map1.zip')
	
	#var result = $Hud.get_result()
	#result.merge({
		#'mark': 'b',
		#'acc': 100,
		#'map_name': 'map1',
		#'nick_name': '???',
		#'map_max_combo': map_max_combo
	#})
	#$Result.show_result(result)
	
	#hits = [
		#{'type': Constants.HitType.RED, 'delay': 1},
		#{'type': Constants.HitType.BLUE, 'delay': 1}, 
		#{'type': Constants.HitType.BIGBLUE, 'delay': 2}, 
		#{'type': Constants.HitType.BIGRED, 'delay': 1},
	#]
	
	var first_hit = hits.pop_front()
	next_hit_type = first_hit.type
	await scene_tree.create_timer(2).timeout
	start_timer = first_hit.delay
	end_timer = first_hit.delay + ar + acc
	await scene_tree.create_timer(ar).timeout
	$MapMusic.play()


func _process(delta: float) -> void:
	if start_timer != null:
		start_timer -= delta
		if start_timer <= 0:
			instantiate_hit(next_hit_type)
			if i < hits.size():
				next_hit_type = hits[i].type
				start_timer += hits[i].delay
				i += 1
			else:
				start_timer = null
	if end_timer != null:
		end_timer -= delta
		if end_timer <= 0:
			$CircleRate.play_animation('bad')
			$Hud.break_combo()
			next_hit()
	
	$Label.text = (str(start_timer) + '\n' + str(end_timer) + '\n' + str(delta) + '\n' + str(i))


func instantiate_hit(hit_type: Constants.HitType) -> void:
	var hit = hit_scene.instantiate()
	hit.type = hit_type
	hit.position = $HitPosition.position
	var distance = $HitPosition.position.x - $CircleRate.position.x
	var velocity = distance / ar
	hit.linear_velocity = Vector2(velocity, 0).rotated(PI)
	add_child(hit)


func next_hit() -> Constants.HitType:
	var new_hit = hits.pop_front()
	i -= 1
	if new_hit:
		end_timer += new_hit.delay
	else: 
		OS.alert('stop')
		end_timer = null
	#проблема с исчезанием?
	var node = scene_tree.get_first_node_in_group('hits')
	var node_type = node.type
	node.free()
	return node_type


func load_map(file_name: String) -> void:
	var reader = ZIPReader.new()
	var err = reader.open(file_name)
	if err != OK:
		OS.alert('Ошибка чтения архива')
	var map = reader.read_file('map1.map').get_string_from_ascii()
	#var map = FileAccess.open('res://resource/map/map1/map1.map.test', FileAccess.READ)
	#hits = JSON.parse_string(map.get_as_text())
	hits = JSON.parse_string(map)
	map_max_combo = hits.size()
	#hits = hits.filter(func(item): return item.id >= 100)
	var map_music = AudioStreamMP3.new()
	map_music.data = reader.read_file('map1.mp3')
	$MapMusic.stream = map_music
	reader.close()


func drum_press(press_type: String) -> void:
	if !end_timer:
		return
	if 0 < end_timer && end_timer <= acc * 2:
		var is_excellent_interval = abs(end_timer - acc) <= acc / 2
		var hit_type = next_hit()
		var is_correct_press = ((press_type == 'inner' || press_type == 'double_inner') &&
			hit_type == Constants.HitType.RED ||
			(press_type == 'outer' || press_type == 'double_outer') &&
			hit_type == Constants.HitType.BLUE)
		var is_correct_double_press = (press_type == 'double_inner' &&
			hit_type == Constants.HitType.BIGRED ||
			press_type == 'double_outer' &&
			hit_type == Constants.HitType.BIGBLUE)
		var is_incorrect_double_press = (press_type == 'inner' &&
			hit_type == Constants.HitType.BIGRED ||
			press_type == 'outer' &&
			hit_type == Constants.HitType.BIGBLUE)
			
		if is_excellent_interval && (is_correct_press || is_correct_double_press):
			$CircleRate.play_animation('excellent')
			$Hud.add_points(300)
		elif (!is_excellent_interval && (is_correct_press || is_correct_double_press) ||
			is_excellent_interval && is_incorrect_double_press):
			$CircleRate.play_animation('good')
			$Hud.add_points(100)
		else:
			$CircleRate.play_animation('bad')
			$Hud.break_combo()
