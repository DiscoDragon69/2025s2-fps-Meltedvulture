extends Node3D

@onready var animationPlayer = $AnimationPlayer
@onready var exitArea = $"Exit Detection"
@onready var timer = $"Timer"

@export var spawnpoint: bool = false
@export var levelToChange: PackedScene
var exited = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawnpoint == true:
		timer.start(1)
		await timer.timeout
		animationPlayer.play("Entrance Level Open")


func changeLevel():
	get_tree().change_scene_to_packed(levelToChange)


func _on_exit_detection_body_entered(body: Node3D) -> void:
	if body == Global.player and exited == false:
		exited = true
		animationPlayer.play("Exit Level Open")


func _on_middle_detection_body_entered(body: Node3D) -> void:
	if body == Global.player and exited == true:
		exited = false
		animationPlayer.play("Exit Level Open", 1, -1, true)
		timer.start(3)
		await timer.timeout
		changeLevel()
		
