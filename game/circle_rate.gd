extends AnimatedSprite2D
var scene_tree

func _ready() -> void:
	scene_tree = get_tree()

func play_animation(anim: String) -> void:
	play(anim)
	await scene_tree.create_timer(0.1).timeout
	play('none')
