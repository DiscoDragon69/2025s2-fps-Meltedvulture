extends RigidBody3D


@onready var weaponMesh : MeshInstance3D = %WeaponMesh
@onready var weaponMagazine : MeshInstance3D = %WeaponMagazine
@onready var weaponBolt : MeshInstance3D = %WeaponBolt
@onready var weaponShadow : MeshInstance3D = %WeaponShadow

@export var objectName : String = ""
var weaponPath

func update():
	pass

func interact():
	Global.weaponManager.addWeapon(weaponPath)
	queue_free()

func setWeapon(path):
	weaponPath = path

func setModel(weaponType):
	var loadedWeapon = load(weaponType)
	objectName = str(loadedWeapon.name)
	weaponMesh.mesh = loadedWeapon.mesh
	weaponMagazine.mesh = loadedWeapon.magazine
	weaponBolt.mesh = loadedWeapon.bolt
	weaponShadow.mesh = loadedWeapon.mesh

func changeVel(vel):
	apply_impulse(vel)
