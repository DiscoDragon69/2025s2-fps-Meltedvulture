extends RigidBody3D


@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponMagazine : MeshInstance3D = %WeaponMagazine
@onready var weaponBolt : MeshInstance3D = %WeaponBolt
@onready var weaponShadow : MeshInstance3D = %WeaponShadow

@export var objectName : String = ""
@export_file("*.tres") var weaponPath

@export var defaultStats = true
@export var clip = 0
@export var reserve = 0
@onready var damageParticle = preload("res://Scenes/Enemy Hurt Effect.tscn")

var weaponWeight = 1

#defaultStats tells the Weapon Manager to use the files default ammo
#Turning it off will pull the ammo from the values here, which are set when the weapon is dropped.
#Can be used to give custom ammo, such as guns with extra ammo, or no ammo for specific level.
func _ready():
	if weaponPath != null:
		setModel(weaponPath)


func update():
	pass

func interact():
	Global.weaponManager.addWeapon(weaponPath, defaultStats, clip, reserve)
	queue_free()

func setWeapon(path):
	weaponPath = path
	defaultStats = false

func parseAmmo(clipAmmo, reserveAmmo):
	clip = clipAmmo
	reserve = reserveAmmo

func setModel(weaponType):
	var loadedWeapon = load(weaponType)
	objectName = str(loadedWeapon.name)
	weaponMesh.mesh = loadedWeapon.mesh
	weaponMagazine.mesh = loadedWeapon.magazine
	weaponBolt.mesh = loadedWeapon.bolt
	weaponShadow.mesh = loadedWeapon.mesh
	weaponWeight = loadedWeapon.weight

func changeVel(vel):
	apply_impulse(vel)

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(linear_velocity.length())
	if linear_velocity.length() > 2 and body.is_in_group("Enemy"):
		body.take_damage(linear_velocity.length() * (2 + weaponWeight))
		linear_velocity = (Vector3(0, 8, 0))
		var instance = damageParticle.instantiate()
		instance.get_child(0).setCount(4 + roundi(linear_velocity.length() / 2))
		instance.global_position = position
		get_tree().root.add_child(instance)
