extends Node

signal inner
signal outer
signal double_inner
signal double_outer

var multiplier = 0
var points = 0
var inner_count = 0
var outer_count = 0
var current_inner_signal
var current_outer_signal


func _process(_delta: float) -> void:
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
	
	$Label.text = str(inner_count) + ' ' + str(outer_count)


func inner_press() -> void:
	$InnerAudio.play()
	if $InnerTimer.is_stopped():
		$InnerTimer.start()
	inner_count += 1
	if inner_count == 2:
		current_inner_signal = double_inner
	else:
		current_inner_signal = inner


func inner_releas() -> void:
	inner_count -= 1


func outer_press() -> void:
	$OuterAudio.play()
	if $OuterTimer.is_stopped():
		$OuterTimer.start()
	outer_count += 1
	if outer_count == 2:
		current_outer_signal = double_outer
	else:
		current_outer_signal = outer


func outer_releas() -> void:
	outer_count -= 1


func add_points(new_points) -> void:
	points += new_points + new_points * multiplier * 0.1
	multiplier += 1
	$Points.text = str(points)
	$Multiplier.text = 'x' + str(multiplier)


func break_multiplier() -> void:
	multiplier = 0
	$Multiplier.text = 'x0'


func _on_inner_timer_timeout() -> void:
	current_inner_signal.emit()
	current_inner_signal = null


func _on_outer_timer_timeout() -> void:
	current_outer_signal.emit()
	current_outer_signal = null
