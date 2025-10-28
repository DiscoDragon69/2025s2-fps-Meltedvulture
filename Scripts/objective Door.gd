extends Node3D

@onready var animationPlayer = $AnimationPlayer
@export var target: Node 
var doorOpened = false

func _process(delta):
	if !is_instance_valid(target) and doorOpened == false:
		doorOpened = true
		animationPlayer.play("Interacted", -1, 1)
