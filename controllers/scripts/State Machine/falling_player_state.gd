class_name FallingPlayerState 

extends PlayerMovementState

@export var speed: float = 6.0
@export var acceleration: float = 0.01
@export var deceleration: float = 0.01

func enter(previous_state) -> void:
	animation.pause()

func exit() -> void:
	pass

func update(delta: float) -> void:
	PLAYER.updateGravity(delta)
	PLAYER.updateInput(speed, acceleration, deceleration)
	PLAYER.updateVelocity()

	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")

	if Input.is_action_just_pressed("shoot"):
		weapon.shoot()
	
	if Input.is_action_just_pressed("sprint") and PLAYER.stamina >= 33:
		transition.emit("DashingPlayerState")
