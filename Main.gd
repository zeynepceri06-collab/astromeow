extends Node2D

func _read()->void:
	HUD.show()

func load_space_flight(direction: String = "OUTBOUND") -> void:
	if has_node("ShipInterior"):
		$ShipInterior.queue_free()
	if has_node("MoonSurface"):
		$MoonSurface.queue_free()
	if has_node("SpaceFlight"):
		$SpaceFlight.queue_free()
		
	var flight_scene = preload("res://SpaceFlight.tscn").instantiate()
	flight_scene.name = "SpaceFlight"
	flight_scene.flight_direction = direction
	add_child(flight_scene)
	move_child(flight_scene, 0)

func load_moon_surface() -> void:
	if has_node("SpaceFlight"):
		$SpaceFlight.queue_free()
	if has_node("ShipInterior"):
		$ShipInterior.queue_free()
		
	var moon_scene = preload("res://MoonSurface.tscn").instantiate()
	moon_scene.name = "MoonSurface"
	add_child(moon_scene)
	move_child(moon_scene, 0)
