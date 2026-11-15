extends Node2D

var flight_direction: String = "OUTBOUND"

@onready var rocket: Node2D = $Rocket
@onready var earth: Node2D = $EarthSprite
@onready var moon: Node2D = $MoonSprite

func _ready() -> void:
	if rocket is AnimatedSprite2D:
		rocket.play()
		
	var start_pos: Vector2
	var end_pos: Vector2
	
	if flight_direction == "OUTBOUND":
		start_pos = earth.position + Vector2(60, 0)
		end_pos = moon.position - Vector2(60, 0)
		rocket.rotation = deg_to_rad(90) 
	else:
		
		start_pos = moon.position - Vector2(60, 0)
		end_pos = earth.position + Vector2(60, 0)
		rocket.rotation = deg_to_rad(-90) 
		
	rocket.position = start_pos
	
	var tween = create_tween()
	tween.tween_property(rocket, "position", end_pos, 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_flight_finished)

func _on_flight_finished() -> void:
	var main_scene = get_tree().current_scene
	if flight_direction == "OUTBOUND":
		GameManager.current_phase = "MOON"
		GameManager.emit_signal("stats_updated")
		if main_scene.has_method("load_moon_surface"):
			main_scene.load_moon_surface()
	else:
		GameManager.current_phase = "RETURN"
		GameManager.emit_signal("stats_updated")
