extends Area2D

@export var rock_type: String = "Basalt"

const ROCK_COLORS = {
	"Basalt": Color(0.35, 0.35, 0.4),
	"Anorthosite": Color(0.9, 0.9, 0.95),
	"Breccia": Color(0.7, 0.5, 0.35),
	"Regolith": Color(0.55, 0.55, 0.55),
	"Ilmenite": Color(0.3, 0.45, 0.7),
	"Olivine": Color(0.45, 0.75, 0.4)
}

const ROCK_INFO = {
	"Basalt": "BASALT: Dark volcanic rock from ancient lunar lava flows (maria). Rich in iron and magnesium.",
	"Anorthosite": "ANORTHOSITE: Bright white rock forming the Moon's ancient highlands. Over 4 billion years old.",
	"Breccia": "BRECCIA: Jagged rock fragments fused together by intense meteorite impact heat.",
	"Regolith": "REGOLITH: Fine, powdery lunar dust and crushed rock created by billions of micrometeorite impacts.",
	"Ilmenite": "ILMENITE: Titanium-iron oxide mineral. Key future resource for extracting oxygen and water on the Moon.",
	"Olivine": "OLIVINE: Greenish magnesium-iron silicate crystal originating deep within the lunar mantle."
}

var is_player_near: bool = false

@onready var info_label: Label = $Label # İçine eklediğin Label'ın adı

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
	GameManager.collect_rock(rock_type)
	queue_free()
	if has_node("Sprite2D") and ROCK_COLORS.has(rock_type):
		$Sprite2D.modulate = ROCK_COLORS[rock_type]

func _process(_delta: float) -> void:
	var player = get_parent().get_node_or_null("CatPlayer")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist < 90.0:
		if not is_player_near:
			is_player_near = true
			var info = ROCK_INFO.get(rock_type, rock_type) + "\n[Press E to Collect]"
			GameManager.emit_signal("rock_hovered", info)
		
		if Input.is_action_just_pressed("interact"):
			GameManager.emit_signal("rock_hovered", "")
			GameManager.collect_rock(rock_type)
			queue_free()
	elif is_player_near:
		is_player_near = false
		GameManager.emit_signal("rock_hovered", "")
