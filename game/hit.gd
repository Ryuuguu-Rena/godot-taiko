extends RigidBody2D

var type: Constants.HitType


func _ready() -> void:
	if type == Constants.HitType.RED:
		$Sprite2D.play('red')
		$Sprite2D.set_scale(Vector2(2, 2))
	elif type == Constants.HitType.BLUE:
		$Sprite2D.play('blue')
		$Sprite2D.set_scale(Vector2(2, 2))
	elif type == Constants.HitType.BIGRED:
		$Sprite2D.play('red')
		$Sprite2D.set_scale(Vector2(3, 3))
	else:
		$Sprite2D.play('blue')
		$Sprite2D.set_scale(Vector2(3, 3))
