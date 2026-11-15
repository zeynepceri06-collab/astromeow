extends Control

func _ready():
	HUD.hide()
	await get_tree().create_timer(2.0).timeout
	
	$LogoScreen.hide()
	$StartButton.show()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
