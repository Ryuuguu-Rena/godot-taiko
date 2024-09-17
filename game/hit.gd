extends RigidBody2D

var type: Constants.HitType


func _ready() -> void:
	if type == Constants.HitType.RED:
		$Sprite2D.play("red")
	elif type == Constants.HitType.BLUE:
		$Sprite2D.play("blue")
