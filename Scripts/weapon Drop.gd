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

func changeVel(vel):
	apply_impulse(vel)
