extends Node

var inner_count = 0
var outer_count = 0
signal inner
signal outer
signal double_inner
signal double_outer


func inner_press() -> void:
	inner_count += 1
	inner.emit()
	if inner_count == 2:
		double_inner.emit()


func inner_releas() -> void:
	inner_count -= 1


func outer_press() -> void:
	outer_count += 1
	outer.emit()
	if outer_count == 2:
		double_outer.emit()


func outer_releas() -> void:
	outer_count -= 1
