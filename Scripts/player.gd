extends CharacterBody3D


const speed = 5.0
const sprintSpeed = 10
const acceleration = 0.1
const jumpVelocity = 4.5
var mouseSensitivity = 0.002

var bulletScene = preload("res://Scenes/Bullet.tscn")
@onready var bulletSpawn = $"Camera3D/Bullet Spawn"
var ammo : int = 5
var player_health = 100

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = lerp(velocity.x,direction.x * sprintSpeed, acceleration)
			velocity.z = lerp(velocity.z,direction.z * sprintSpeed, acceleration)
		else:
			velocity.x = lerp(velocity.x,direction.x * speed, acceleration)
			velocity.z = lerp(velocity.z,direction.z * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration)
		velocity.z = lerp(velocity.z, 0.0, acceleration)
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouseSensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouseSensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func shoot():
	var bullet = bulletScene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_transform = bulletSpawn.global_transform
	bullet.scale = Vector3(0.25, 0.25, 0.25)
	ammo -= 1
