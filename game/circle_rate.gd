extends AnimatedSprite2D


func play_animation(anim: String) -> void:
	$AnimTimer.start(0.1)
	play(anim)


func _on_anim_timer_timeout() -> void:
	play('none')
