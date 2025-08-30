@tool

extends Node3D

class_name WeaponController

# OnReady variables
@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponMagazine : MeshInstance3D = %WeaponMagazine
@onready var weaponBolt : MeshInstance3D = %WeaponBolt
@onready var weaponShadow : MeshInstance3D = %WeaponShadow
@onready var bulletSpawnPoint = %"Bullet Spawn"

# Exported variables
@export var weaponType : Weapons:
	set(value):
		weaponType = value
		if Engine.is_editor_hint():
			loadWeapon()

@export var swaySpeed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			loadWeapon()

#********Animation names Index:********
		# "fullReload"
		# "emptyReload"
		# "startReload"
		# "finishReload"
		# "shellReload"
		# "boltCycle"
		# "shoot"
		
		# Documemtation stuff:
		# Magazine reloads are for guns where all ammo is loaded at once
		# Shell reloads are for guns where they load individual rounds

# Internal variables


@export var weaponAnimationPlayer : AnimationPlayer

var weaponDrop = preload("res://Scenes/Weapon Drop.tscn")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.reserveLabel = %Reserve
	Global.clipLabel = %Clip
	Global.pointsLabel = %Points
	Global.healthLabel = %Health
	Global.weaponManager = self
	#weaponInventory.resize(1)
	if weaponGlobal.hasSpawned == false:
		addWeapon("res://Weapons/Empty Weapon.tres")
		addWeapon("res://Weapons/Empty Weapon.tres")
		addWeapon("res://Weapons/Blaster.tres")
		addWeapon("res://Weapons/Blaster.tres")
		weaponGlobal.hasSpawned = true
		loadWeapon()

func _input(event):
	if event.is_action_pressed("weaponDown"):
		if !weaponAnimationPlayer.is_playing():
			switchWeapon(1)

	if event.is_action_pressed("weaponUp"):
		if !weaponAnimationPlayer.is_playing():
			switchWeapon(-1)
	
	if Input.is_action_just_pressed("dropWeapon"):
		dropWeapon()
	
	if event is InputEventMouseMotion:
		weaponGlobal.mouseMovement = event.relative

func addWeapon(WeaponPath: String):
	if weaponType == load("res://Weapons/Empty Weapon.tres") or null:
		weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex] = WeaponPath
		var weapon = load(WeaponPath)
		weaponGlobal.currentWeaponPath = WeaponPath
		weaponGlobal.weaponAmmoInventory[weaponGlobal.currentWeaponIndex] = [weapon.clip, weapon.reserve]
	else:
		if weaponGlobal.weaponInventory.size() < weaponGlobal.maxInventorySize:
			weaponGlobal.weaponInventory.append(WeaponPath)
			var weapon = load(WeaponPath)
			weaponGlobal.currentWeaponPath = WeaponPath
			weaponGlobal.weaponAmmoInventory.append([weapon.clip, weapon.reserve])
		else:
			if weaponType != load("res://Weapons/Empty Weapon.tres"):
				dropWeapon()
			weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex] = WeaponPath
			var weapon = load(WeaponPath)
			weaponGlobal.currentWeaponPath = WeaponPath
			weaponGlobal.weaponAmmoInventory[weaponGlobal.currentWeaponIndex] = [weapon.clip, weapon.reserve]

	loadWeapon()

func switchWeapon(direction: int) -> void:
	# Increment or decrement the current weapon index based on the direction
	weaponGlobal.currentWeaponIndex += direction
	
	# Use modulo (%) to loop the index within the bounds of the array
	# Ensure it works correctly for negative indices by adding maxInventorySize before taking the modulus
	weaponGlobal.currentWeaponIndex = wrap_index(weaponGlobal.currentWeaponIndex, weaponGlobal.weaponInventory.size())
	# Equip the weapon at the new index
	loadWeapon()


func wrap_index(index: int, size: int) -> int:
	# Wrap the index to stay within [0, size)
	if size == 0:
		return 0  # Avoid division by zero if the inventory is empty
	return (index % size + size) % size


func loadWeapon():
	if weaponType == null:
		return
	
	if weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex] != null:
		weaponType = load(weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex])
	else:
		weaponType = load("res://Weapons/Empty Weapon.tres")
		
	weaponGlobal.weaponName = weaponType.name
	weaponMesh.mesh = weaponType.mesh
	weaponMagazine.mesh = weaponType.magazine
	weaponBolt.mesh = weaponType.bolt
	weaponShadow.mesh = weaponType.mesh
	
	weaponGlobal.weaponBulletPhysics = weaponType.bulletPhysics
	weaponGlobal.weaponBulletScene = load(weaponType.bulletScene)
	
	position = weaponType.position
	rotation_degrees = weaponType.rotation
	scale = weaponType.scale
	weaponShadow.visible = weaponType.shadow
	weaponGlobal.idleSwayAdjustment = weaponType.idleSwayAdjustment
	weaponGlobal.idleSwayRotationStrength = weaponType.idleSwayRotationStrength
	weaponGlobal.randomSwayAmount = weaponType.randomSwayAmount

	weaponGlobal.shotgun = weaponType.shotgun
	weaponGlobal.fireMode = weaponType.fireMode
	weaponGlobal.reloadMode = weaponType.reloadMode

	# Load ammo from weaponAmmoInventory instead of resetting to default
	if weaponGlobal.currentWeaponIndex < weaponGlobal.weaponAmmoInventory.size():
		var ammo_data = weaponGlobal.weaponAmmoInventory[weaponGlobal.currentWeaponIndex]
		weaponGlobal.clipAmmo = ammo_data[0]
		weaponGlobal.reserveAmmo = ammo_data[1]
	else:
		weaponGlobal.clipAmmo = weaponType.clip
		weaponGlobal.reserveAmmo = weaponType.reserve
		weaponGlobal.weaponAmmoInventory.append([weaponGlobal.clipAmmo, weaponGlobal.reserveAmmo])

	weaponGlobal.maxClipAmmo = weaponType.maxClip
	Global.clipLabel.text = str(weaponGlobal.clipAmmo)
	Global.reserveLabel.text = str(weaponGlobal.reserveAmmo)
	weaponGlobal.time_per_shot = 60.0 / weaponType.rpm
	weaponGlobal.weaponAccuracy = weaponType.Accuracy

func sway_weapon(delta, isIdle: bool) -> void:
	if weaponType == null:
		return
		
	# Clamp mouse movement
	weaponGlobal.mouseMovement.x = clamp(weaponGlobal.mouseMovement.x, weaponType.sway_min.x, weaponType.sway_max.x)
	weaponGlobal.mouseMovement.y = clamp(weaponGlobal.mouseMovement.y, weaponType.sway_min.y, weaponType.sway_max.y)
	
	#Idle Bob
	if isIdle:
		# Get sway noise
		var swayRandom : float = getSwayNoise()
		var swayRandomAdjusted = swayRandom * weaponGlobal.idleSwayAdjustment

		# Update time for sine waves
		weaponGlobal.time += delta * (swaySpeed + swayRandom)

		# Calculate random sway
		weaponGlobal.randomSwayX = sin(weaponGlobal.time * 1.5 + swayRandomAdjusted)
		weaponGlobal.randomSwayY = sin(weaponGlobal.time - swayRandomAdjusted)

	# Lerp weapon position
		if weaponGlobal.randomSwayAmount != 0:
			weaponGlobal.randomSwayX /= weaponGlobal.randomSwayAmount
			weaponGlobal.randomSwayY /= weaponGlobal.randomSwayAmount

		position.x = lerp(position.x, weaponType.position.x - (weaponGlobal.mouseMovement.x * weaponType.swayAmountPosition + weaponGlobal.randomSwayX) * delta, weaponType.swaySpeedPosition)
		position.y = lerp(position.y, weaponType.position.y + (weaponGlobal.mouseMovement.y * weaponType.swayAmountPosition + weaponGlobal.randomSwayY) * delta, weaponType.swaySpeedPosition)

		# Lerp weapon rotation
		rotation_degrees.y = lerp(rotation_degrees.y, weaponType.rotation.y + (weaponGlobal.mouseMovement.x * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weaponType.rotation.x - (weaponGlobal.mouseMovement.y * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
	
	#Movement bob (Not idle)
	else:
		position.x = lerp(position.x, weaponType.position.x - (weaponGlobal.mouseMovement.x * weaponType.swayAmountPosition + weaponGlobal.weaponBobAmount.x) * delta, weaponType.swaySpeedPosition)
		position.y = lerp(position.y, weaponType.position.y + (weaponGlobal.mouseMovement.y * weaponType.swayAmountPosition + weaponGlobal.weaponBobAmount.y) * delta, weaponType.swaySpeedPosition)
		# Lerp weapon rotation
		rotation_degrees.y = lerp(rotation_degrees.y, weaponType.rotation.y + (weaponGlobal.mouseMovement.x * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weaponType.rotation.x - (weaponGlobal.mouseMovement.y * weaponType.swayAmountRotation) * delta, weaponType.swaySpeedRotation)

func weaponBob(delta, bobSpeed: float, hbobAmount: float, vbobAmount) -> void:
	weaponGlobal.time += delta
	
	weaponGlobal.weaponBobAmount.x = sin(weaponGlobal.time * bobSpeed) * hbobAmount
	weaponGlobal.weaponBobAmount.y = abs(cos(weaponGlobal.time * bobSpeed) * vbobAmount)
	
func getSwayNoise() -> float: 
	var noiseLocation : float = weaponGlobal.rng.randf_range(0, 1.0)
	return noiseLocation

func shoot() -> void:
	if weaponGlobal.clipAmmo != 0 and weaponGlobal.canShoot == true and weaponType != load("res://Weapons/Empty Weapon.tres"):
		# Trigger the shot
		weaponGlobal.canShoot = false  # Prevent further shooting
		weaponGlobal.cooldown_timer = weaponGlobal.time_per_shot  # Reset the cooldown timer
		
		if weaponGlobal.weaponBulletPhysics == "Hitscan":
			#Run Raycast function
			var camera = Global.player.CAMERA_CONTROLLER
			var spaceState = camera.get_world_3d().direct_space_state
			var screenCenter = get_viewport().size / 2
			var origin = camera.project_ray_origin(screenCenter)
			
			if weaponGlobal.shotgun:
				for i in 8:
					var accuracyAdjustment = Vector3 (
					weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
					weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
					weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy)
					)
					

					var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000 + accuracyAdjustment * 10
					var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
					query.collide_with_bodies = true
					var result = spaceState.intersect_ray(query)
					
					var hitPosition = result.get("position")
					var hitNormal = result.get("normal")
					var hitBody = result.get("collider")  # Get the object that was hit
					if hitBody and hitBody.has_method("take_damage"):
						hitBody.take_damage(weaponType.Damage)  # Deal damage to the enemy
					
			else:
				var accuracyAdjustment = Vector3 (
				weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy)
				)
					

				var endpoint = origin + camera.project_ray_normal(screenCenter) * 1000 + accuracyAdjustment * 10
				var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
				query.collide_with_bodies = true
				var result = spaceState.intersect_ray(query)
					
				var hitPosition = result.get("position")
				var hitNormal = result.get("normal")
				var hitBody = result.get("collider")  # Get the object that was hit
				if hitBody and hitBody.has_method("take_damage"):
					hitBody.take_damage(weaponType.Damage)  # Deal damage to the enemy
				
		if weaponGlobal.weaponBulletPhysics == "Projectile":
			var bulletInstance = weaponGlobal.weaponBulletScene.instantiate()
			var accuracyAdjustment = Vector3 (
				weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy),
				weaponGlobal.rng.randf_range(-weaponType.Accuracy, weaponType.Accuracy)
			)
			bulletInstance.global_transform = bulletSpawnPoint.global_transform
			bulletInstance.rotation += accuracyAdjustment / 100
			bulletInstance.scale = Vector3(0.25, 0.25, 0.25)
			get_tree().get_root().add_child(bulletInstance)
			
		weaponGlobal.clipAmmo -= 1
		weaponGlobal.weaponAmmoInventory[weaponGlobal.currentWeaponIndex][0] = weaponGlobal.clipAmmo
		Global.updateLabels(weaponGlobal.clipAmmo, weaponGlobal.reserveAmmo) 
		weaponAnimationPlayer.stop()
		weaponAnimationPlayer.seek(0)
		weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "shoot", -1, 2, false)
		

		if weaponGlobal.fireMode == "Bolt":
			await weaponAnimationPlayer.animation_finished
			weaponGlobal.weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "boltCycle", -1, 1, false)
			
	elif weaponGlobal.reserveAmmo > 0 and weaponGlobal.clipAmmo == 0:
		reloadWeapon()
		return


func reloadWeapon():
	weaponGlobal.canShoot = false
	weaponGlobal.cooldown_timer = 100
	if weaponGlobal.reloadMode == "Shell":
		var ammoNeeded = weaponGlobal.maxClipAmmo - weaponGlobal.clipAmmo
		weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "startReload", -1, 1, false)
		await weaponAnimationPlayer.animation_finished
		for n in ammoNeeded:
			weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "shellReload", -1, 1, false)
			weaponGlobal.reserveAmmo -= 1
			weaponGlobal.clipAmmo += 1
			await weaponAnimationPlayer.animation_finished
		weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "finishReload", -1, 1, false)
	else:
		if weaponGlobal.clipAmmo > 0:
			weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "fullReload", -1, 1, false)
			await weaponAnimationPlayer.animation_finished
		else:
			weaponAnimationPlayer.play(weaponGlobal.weaponName + "/" + "emptyReload", -1, 1, false)
			await weaponAnimationPlayer.animation_finished
		var ammoNeeded = weaponGlobal.maxClipAmmo - weaponGlobal.clipAmmo
		if weaponGlobal.reserveAmmo >= ammoNeeded:
			weaponGlobal.reserveAmmo -= ammoNeeded
			weaponGlobal.clipAmmo = weaponGlobal.maxClipAmmo
		else:
			weaponGlobal.clipAmmo += weaponGlobal.reserveAmmo
			weaponGlobal.reserveAmmo = 0

	Global.updateLabels(weaponGlobal.clipAmmo, weaponGlobal.reserveAmmo)
	weaponGlobal.weaponAmmoInventory[weaponGlobal.currentWeaponIndex] = [weaponGlobal.clipAmmo, weaponGlobal.reserveAmmo]
	weaponGlobal.canShoot = true
	weaponGlobal.cooldown_timer = 0

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if weaponGlobal.cooldown_timer > 0:
			weaponGlobal.cooldown_timer -= delta  # Decrease the cooldown timer
		else:
			weaponGlobal.canShoot = true  # Allow shooting once the cooldown ends
			if weaponGlobal.fireMode == "Auto" and Input.is_action_pressed("shoot"):
				shoot()
		
		
	if !Engine.is_editor_hint():
		if Input.is_action_just_pressed("reload") and weaponGlobal.clipAmmo != weaponGlobal.maxClipAmmo:
			reloadWeapon()


func removeHitMark(Instance):
	await get_tree().create_timer(weaponGlobal.rng.randi_range(4, 12)).timeout
	Instance.queue_free()

func dropWeapon():
	if weaponType != load("res://Weapons/Empty Weapon.tres"):
		var dropInstance = weaponDrop.instantiate()
		dropInstance.global_transform = bulletSpawnPoint.global_transform
		get_tree().get_root().add_child(dropInstance)
		dropInstance.setWeapon(weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex])
		dropInstance.setModel(weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex])
		dropInstance.changeVel((bulletSpawnPoint.transform.basis.z.normalized() + Global.player.velocity) * 1.25)
		weaponGlobal.weaponInventory[weaponGlobal.currentWeaponIndex] = null
		loadWeapon()

#func _physics_process(delta) -> void:


#✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
