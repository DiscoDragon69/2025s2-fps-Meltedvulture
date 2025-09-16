extends StaticBody3D

class_name toggleable

@export var health = 200
@export var spawnRange = 2
@export var spawnCooldown: float = 3
@export var enabled : bool = false
var loadedEnemy
var rng = RandomNumberGenerator.new()
@onready var spawnTimer = $"Spawn Timer"

@export_file("*.tscn") var enemyType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	spawnTimer.wait_time = spawnCooldown
	if !enemyType:
		print("NO ENEMY IN SPAWNER NOT LOADING")
	else:
		loadedEnemy = load(enemyType)


func take_damage(damage):
	health -= damage
	if health <=0:
		queue_free()


func _on_spawn_timer_timeout() -> void:
	if enabled:
		var enemyInstance = loadedEnemy.instantiate()
		enemyInstance.position = position + Vector3(rng.randf_range(-spawnRange, spawnRange), 0, rng.randf_range(-spawnRange, spawnRange) )
		get_tree().get_root().add_child(enemyInstance)
