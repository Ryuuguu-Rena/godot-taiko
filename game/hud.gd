extends Node

signal inner
signal outer
signal double_inner
signal double_outer

var combo = 0
var max_combo = 0
var exc_count = 0
var god_count = 0
var bad_count = 0
var points = 0
var inner_count = 0
var outer_count = 0
var current_inner_signal
var current_outer_signal
var inner_timer
var outer_timer
var is_desktop

func _ready() -> void:
	var os_name = OS.get_name()
	is_desktop = os_name == 'Linux' || os_name == 'Windows'
	
	var drum_img = $Drum.texture.get_image()
	var drum_width = drum_img.get_width()
	var drum_height = drum_img.get_height()
	
	var left_drum_rect = Rect2i(0, 0, ceili(drum_width / 2), drum_height)
	var left_drum_img = drum_img.get_region(left_drum_rect)
	var inner_left_bitmap = BitMap.new()
	inner_left_bitmap.create_from_image_alpha(left_drum_img)
	$InnerLeft.bitmask = inner_left_bitmap
	#$InnerLeft.texture_normal = ImageTexture.create_from_image(inner_left_bitmap.convert_to_image())
	
	var right_drum_rect = Rect2i(ceili(drum_width / 2), 0, floori(drum_width / 2), drum_height)
	var right_drum_img = drum_img.get_region(right_drum_rect)
	var inner_right_bitmap = BitMap.new()
	inner_right_bitmap.create_from_image_alpha(right_drum_img)
	$InnerRight.bitmask = inner_right_bitmap
	#$InnerRight.texture_normal = ImageTexture.create_from_image(inner_right_bitmap.convert_to_image())
	
	var outer_left_bitmap = BitMap.new()
	outer_left_bitmap.create(Vector2i(960, 600))
	outer_left_bitmap.set_bit_rect(Rect2i(0, 0, 510, 600), true)
	outer_left_bitmap.set_bit_rect(Rect2i(510, 0, 450, 88), true)
	for i in range(510, 960):
		for j in range(88, 600):
			if outer_left_bitmap.get_bit(i, j) == inner_left_bitmap.get_bit(i - 510, j - 88):
				outer_left_bitmap.set_bit(i, j, true)
	$OuterLeft.bitmask = outer_left_bitmap
	#$OuterLeft.texture_normal = ImageTexture.create_from_image(outer_left_bitmap.convert_to_image())
	
	var outer_right_bitmap = BitMap.new()
	outer_right_bitmap.create(Vector2i(960, 600))
	outer_right_bitmap.set_bit_rect(Rect2i(450, 0, 510, 600), true)
	outer_right_bitmap.set_bit_rect(Rect2i(0, 0, 450, 88), true)
	for i in range(0, 450):
		for j in range(88, 600):
			if outer_right_bitmap.get_bit(i, j) == inner_right_bitmap.get_bit(i, j - 88):
				outer_right_bitmap.set_bit(i, j, true)
	$OuterRight.bitmask = outer_right_bitmap
	#$OuterRight.texture_normal = ImageTexture.create_from_image(outer_right_bitmap.convert_to_image())

func _process(delta: float) -> void:
	if is_desktop:
		if (Input.is_action_just_pressed('inner_left') ||
			Input.is_action_just_pressed('inner_right')):
			inner_press()
		elif (Input.is_action_just_pressed('outer_left') || 
			Input.is_action_just_pressed('outer_right')):
			outer_press()
		elif (Input.is_action_just_released('inner_left') || 
			Input.is_action_just_released('inner_right')):
			inner_releas()
		elif (Input.is_action_just_released('outer_left') || 
			Input.is_action_just_released('outer_right')):
			outer_releas()
	
	if outer_timer:
		outer_timer -= delta
		if outer_timer <= 0:
			current_outer_signal.emit()
			current_outer_signal = null
			outer_timer = null
	if inner_timer:
		inner_timer -= delta
		if inner_timer <= 0:
			current_inner_signal.emit()
			current_inner_signal = null
			inner_timer = null
	
	$Label.text = str(inner_count) + ' ' + str(outer_count)


func inner_press() -> void:
	$InnerAudio.play()
	if !inner_timer:
		inner_timer = 0.01
	inner_count += 1
	if inner_count == 2:
		current_inner_signal = double_inner
	else:
		current_inner_signal = inner


func inner_releas() -> void:
	inner_count -= 1


func outer_press() -> void:
	$OuterAudio.play()
	if !outer_timer:
		outer_timer = 0.01
	outer_count += 1
	if outer_count == 2:
		current_outer_signal = double_outer
	else:
		current_outer_signal = outer


func outer_releas() -> void:
	outer_count -= 1


func add_points(new_points) -> void:
	points += new_points + new_points * combo * 0.1
	combo += 1
	$Points.text = str(points)
	$Combo.text = 'x' + str(combo)


func break_combo() -> void:
	combo = 0
	$Combo.text = 'x0'


func get_result() -> Dictionary:
	return {
		'points': points,
		'exc_count': exc_count,
		'god_count': god_count,
		'bad_count': bad_count,
		'max_combo': max_combo
	}
