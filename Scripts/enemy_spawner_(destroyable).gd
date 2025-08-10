extends StaticBody3D

var health = 250
var loadedEnemy
var rng = RandomNumberGenerator.new()
var spawnRange = 2

@export_file("*.tscn") var enemyType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	if !enemyType:
		print("NO ENEMY IN SPAWNER NOT LOADING")
	else:
		loadedEnemy = load(enemyType)


func take_damage(damage):
	health -= damage
	if health <=0:
		queue_free()


func _on_spawn_timer_timeout() -> void:
	var enemyInstance = loadedEnemy.instantiate()
	enemyInstance.position = position + Vector3(rng.randf_range(-spawnRange, spawnRange), 0, rng.randf_range(-spawnRange, spawnRange) )
	get_tree().get_root().add_child(enemyInstance)
