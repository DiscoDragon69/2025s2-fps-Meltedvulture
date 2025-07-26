extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var attackCast = $"Attack Shape Cast"
@onready var attackTimer = $"Attack Timer"
var speed = 3.0
var health = 100

func update_target_location (target_location):
	nav_agent.set_target_position(target_location)


func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	look_at(Global.player.global_transform.origin) # Enemy will turn to face player
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Vector Maths
	var new_veloicty = (next_location-current_location).normalized() * speed

	velocity = new_veloicty
	
	update_target_location(Global.player.global_transform.origin)
	move_and_slide()

	if attackCast.is_colliding():
		for i in attackCast.get_collision_count():
			if attackCast.get_collider(i).has_method("take_damage"):
				attackCast.get_collider(i).take_damage(10)
				attackCast.enabled = false
				attackCooldown()

func attackCooldown():
	attackTimer.start(1)
	await attackTimer.timeout
	attackCast.enabled = true

func take_damage(damage):
	health -= damage
	if health <=0:
		queue_free()
