extends Node3D

@onready var animationPlayer = $"../../AnimationPlayer"
@export var objectName : String = "Door"
@export var toggledOnOpen: Array[toggleable]
var doorOpened = false

func update():
	pass

func interact():
	if doorOpened == false:
		doorOpened = true
		animationPlayer.play("Interacted", -1, 1)
		for i in toggledOnOpen:
			i.enabled = !i.enabled
