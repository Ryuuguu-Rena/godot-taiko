extends AnimatedSprite2D


func play_animation(animation: String) -> void:
	$AnimTimer.start(0.1)
	play(animation)


func _on_anim_timer_timeout() -> void:
	play('none')
