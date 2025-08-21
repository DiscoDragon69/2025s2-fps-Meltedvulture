extends Node3D

@onready var animationPlayer = $"../../AnimationPlayer"
@export var objectName : String = "Door"
var doorOpened = false

func update():
	pass

func interact():
	if doorOpened == false:
		doorOpened = true
		animationPlayer.play("Interacted", -1, 1)
