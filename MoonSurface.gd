extends Node2D

var rock_scene = preload("res://LunarRock.tscn")

func _ready() -> void:
	spawn_15_random_rocks()

func spawn_15_random_rocks() -> void:
	var rocks_to_spawn: Array[String] = []
	
	# 1. Guarantee all 5 target rocks are included on the Moon
	for rock_type in GameManager.target_rocks.keys():
		var count = GameManager.target_rocks[rock_type]
		for i in range(count):
			rocks_to_spawn.append(rock_type)
	
	# 2. Fill the remaining 10 slots with random distractor rocks
	while rocks_to_spawn.size() < 15:
		rocks_to_spawn.append(GameManager.all_rock_types.pick_random())
	
	# 3. Spawn all 15 at random positions inside the screen (avoiding the top-left HUD)
	var placed_positions: Array[Vector2] = []
	for rock_type in rocks_to_spawn:
		var rock = rock_scene.instantiate()
		rock.rock_type = rock_type
		rock.position = get_valid_random_position(placed_positions)
		placed_positions.append(rock.position)
		add_child(rock)

func get_valid_random_position(existing: Array[Vector2]) -> Vector2:
	for attempt in range(30):
		var pos = Vector2(randf_range(280, 1050), randf_range(100, 560))
		var too_close = false
		for other in existing:
			if pos.distance_to(other) < 75.0:
				too_close = true
				break
		if not too_close:
			return pos
	return Vector2(randf_range(280, 1050), randf_range(100, 560))
