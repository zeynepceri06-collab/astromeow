extends Area2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		var player = get_parent().get_node_or_null("CatPlayer")
		if player and global_position.distance_to(player.global_position) < 120.0:
			var current = get_tree().current_scene
			if current.has_method("load_launch_cutscene"):
				current.load_launch_cutscene()
			else:
				get_tree().change_scene_to_file("res://LaunchCutscene.tscn")
