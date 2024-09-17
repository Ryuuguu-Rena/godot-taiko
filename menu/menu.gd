extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var maps = ['карта1', '2', 'map3']
	$ItemList.list = maps


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
