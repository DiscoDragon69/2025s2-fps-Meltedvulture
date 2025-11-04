extends Node3D

@onready var animationPlayer = $AnimationPlayer
@export var target: Node 
@export var toggledOnOpen: Array[toggleable]
var doorOpened = false

func _process(delta):
	if !is_instance_valid(target) and doorOpened == false:
		doorOpened = true
		animationPlayer.play("Interacted", -1, 1)
		for i in toggledOnOpen:
			i.enabled = !i.enabled
