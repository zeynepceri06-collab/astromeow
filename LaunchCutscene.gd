extends Node2D

@onready var ship = $ShipSprite
@onready var earth = $EarthSprite
@onready var moon = $MoonSprite
@onready var status_label = $Label

const LAUNCH_MESSAGES = [
	"Moon is 3.7x smaller than Earth!",
	"Moon's mass is 73,476,730,924,573,500,000,000 kg!",
	"Moon's radius is 1,737.5 km!"
]

func _ready() -> void:
	HUD.visible = false
	status_label.text = LAUNCH_MESSAGES.pick_random()
	ship.global_position = earth.global_position
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(ship, "global_position", moon.global_position, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(ship, "scale", Vector2(0.4, 0.4), 2.0)
	
	await tween.finished
	HUD.visible = true
	GameManager.start_moon_phase()
	
	var current = get_tree().current_scene
	if current.has_method("load_moon_surface"):
		current.load_moon_surface()
	else:
		get_tree().change_scene_to_file("res://MoonSurface.tscn")
