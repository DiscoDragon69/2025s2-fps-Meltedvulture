extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Sets the button to be the centre of the screen
	#$DevelopmentLevel.position = get_viewport_rect().size / 2
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Levels/Tutorial.tscn")
