extends CharacterBody2D

@export var speed: float = 250.0
var nearby_interactable: Node = null

func _physics_process(_delta: float) -> void:
	# 8-directional movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	global_position.x = clamp(global_position.x, 32.0, screen_size.x - 32.0)
	global_position.y = clamp(global_position.y, 32.0, screen_size.y - 32.0)
	
	# Flip sprite based on movement
	if direction.x != 0:
		$Sprite2D.flip_h = direction.x < 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearby_interactable != null:
		if nearby_interactable.has_method("interact"):
			nearby_interactable.interact()
