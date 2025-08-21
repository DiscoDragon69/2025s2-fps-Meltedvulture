class_name DashingPlayerState 

extends PlayerMovementState

@export var SPEED: float = 8.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var Camera: Camera3D

func enter(previous_state) -> void:
	PLAYER.velocity += -Camera.global_transform.basis.z.normalized() * SPEED
	print(-Camera.global_transform.basis.z.normalized() * SPEED)

func exit() -> void:
	pass

func update(delta: float) -> void:
	PLAYER.updateGravity(delta)
	PLAYER.updateVelocity()
	
	if PLAYER.velocity.y < -2.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
