extends Area2D

@export_enum("polyethylene", "space_food", "mli") var task_id: String = "polyethylene"
@export var work_required: float = 2.0 # Seconds to hold interact or press

var is_completed: bool = false
@onready var info_label: Label = $Label

func _ready() -> void:
	if info_label:
		info_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CatPlayer":
		body.nearby_interactable = self
		if info_label:
			info_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "CatPlayer" and body.nearby_interactable == self:
		body.nearby_interactable = null
		if info_label:
			info_label.visible = false

func interact() -> void:
	if not is_completed:
		is_completed = true
		GameManager.complete_task(task_id)
		modulate = Color(0.5, 1.0, 0.5) # Turn green to show completion
