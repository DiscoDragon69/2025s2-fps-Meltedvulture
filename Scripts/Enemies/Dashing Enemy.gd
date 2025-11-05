extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var attackCast = $"Attack Shape Cast"
@onready var attackTimer = $"Attack Timer"

var Drop = preload("res://Scenes/Pickup.tscn")
@export var speed = 28.0
@export var health = 100

@export var bulletImmunity = false
@export var throwImmunity = false
var rng = RandomNumberGenerator.new()

var new_velocity

func update_target_location (target_location):
	nav_agent.set_target_position(target_location)


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = move_toward(velocity.x, 0, 0.25)
	velocity.z = move_toward(velocity.z, 0, 0.25)
	move_and_slide()

	if attackCast.is_colliding():
		for i in attackCast.get_collision_count():
			if attackCast.get_collider(i) == null:
				pass
			else:
				if attackCast.get_collider(i).is_in_group("Enemy") == false:
					if attackCast.get_collider(i).has_method("take_damage"):
						attackCast.get_collider(i).take_damage(10, "bullet")
						attackCast.enabled = false
						attackCooldown()

func attackCooldown():
	attackTimer.start(1)
	await attackTimer.timeout
	attackCast.enabled = true

func take_damage(damage, damageType):
	if damageType == "bullet" and bulletImmunity == false:
		health -= damage
	elif damageType == "throw" and throwImmunity == false:
		health -= damage
	if health <=0:
		for i in rng.randi_range(1, 6):
			var droppedPoint = Drop.instantiate()
			var randomForce = Vector3(rng.randf_range(-5, 5), rng.randf_range(0, 8), rng.randf_range(-5, 5))
			get_parent().add_child(droppedPoint)
			droppedPoint.transform = self.transform
			droppedPoint.apply_central_impulse(randomForce)
		queue_free()


func _on_vision_timer_timeout() -> void:
	var origin = position
	var endpoint = Global.player.global_position + Vector3(0, 0.75, 0)
	var spaceState = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var result = spaceState.intersect_ray(query)
	var hitBody = result.get("collider")
	if hitBody.owner == Global.player:
		update_target_location(Global.player.global_transform.origin)
		look_at(Global.player.global_position + Vector3(0, 1, 0)) # Enemy will turn to face player


func _on_dash_timer_timeout() -> void:
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()

	new_velocity = (next_location-current_location).normalized() * speed
	new_velocity.y = (Global.player.global_position.y - global_position.y) * 2

	velocity = new_velocity
	
