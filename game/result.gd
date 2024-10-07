extends Control


func show_result(result: Dictionary) -> void:
	show()
	$Mark.text = result.mark
	$Nickname.text = result.nick_name
	$Mapname.text = result.map_name
	$Points/Value.text = str(result.points)
	$Accuracy/Value.text = str(result.acc) + '%'
	$MaxCombo/Value.text = str(result.max_combo) + str(result.map_max_combo)
	$ExcCount/Value.text = str(result.exc_count)
	$GodCount/Value.text = str(result.god_count)
	$BadCount/Value.text = str(result.bad_count)
