extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var attackTimer = $"Attack Timer"
@onready var bulletSpawn = $BulletSpawn

var pointDrop = preload("res://Scenes/Point Pickup.tscn")
var bulletScene = preload("res://Scenes/Enemy Bullet.tscn")
var speed = 6.0
var health = 150
var rng = RandomNumberGenerator.new()
var canShoot = true


func update_target_location (target_location):
	nav_agent.set_target_position(target_location)


func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Vector Maths
	var new_veloicty = (next_location-current_location).normalized() * speed

	velocity = new_veloicty
	
	move_and_slide()

	if canShoot == true:
		var bullet = bulletScene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_transform = bulletSpawn.global_transform
		bullet.scale = Vector3(0.25, 0.25, 0.25)
		canShoot = false
		attackCooldown()

func attackCooldown():
	attackTimer.start(1)
	await attackTimer.timeout
	canShoot = true

func take_damage(damage):
	health -= damage
	if health <=0:
		for i in rng.randi_range(1, 6):
			var droppedPoint = pointDrop.instantiate()
			var randomForce = Vector3(rng.randf_range(-5, 5), rng.randf_range(0, 8), rng.randf_range(-5, 5))
			get_parent().add_child(droppedPoint)
			droppedPoint.transform = self.transform
			droppedPoint.apply_central_impulse(randomForce)
			droppedPoint.apply_torque(randomForce)
		queue_free()


func _on_vision_timer_timeout() -> void:
	var origin = position
	var endpoint = Global.player.global_position + Vector3(0, 1, 0)
	var spaceState = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var result = spaceState.intersect_ray(query)
	var hitBody = result.get("collider")
	canShoot = false
	if hitBody == Global.player:
		canShoot = true
		update_target_location(Global.player.global_transform.origin)
		look_at(Global.player.global_position + Vector3(0, 1, 0)) # Enemy will turn to face player
	
