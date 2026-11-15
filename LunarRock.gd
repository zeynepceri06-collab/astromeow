extends Area2D

@export var rock_type: String = "Basalt"

const ROCK_COLORS = {
	"HIGH TI BASALT": Color(0.8, 0.4, 0.45),
	"Pyroclastic-glass Breccia": Color(0.9, 0.9, 0.95),
	"Troctolite": Color(0.7, 0.5, 0.35),
	"Shocked Norite": Color(0.55, 0.55, 0.55),
	"Ferroan Anorthosite": Color(0.3, 0.45, 0.7),
	"Glass-Coated Dimict Breccia": Color(0.45, 0.75, 0.4),
	"Regolith Breccia": Color(0.85, 0.7, 0.25),
	"Granitic Breccia": Color(0.35, 0.35, 0.4)
}

const ROCK_INFO = {
	"HIGH TI BASALT": "After erupting to the lunar surface in a period of high volcanic activity, the material that would become basalt endured a long period of cooling, slowly crystalizing from a magma to form the basaltic floor. ",
	"Pyroclastic-glass Breccia": "This rock is thought to be a compacted volcanic glass deposit. Likely formed when fragments of glass and rock ejected from local volcanic vents were lithified.",
	"Troctolite": " It appears almost gem-like due to its atypical luster and color  and has a unique crystalline structure.",
	"Shocked Norite": "It is mafic, meaning it has an igneous origin and is rich in iron and magnesium.",
	"Ferroan Anorthosite": "Being less dense than the magma, this light-colored mineral floated to the top of the magma ocean, forming the Moon's first crust around 4.4 billion years ago.",
	"Glass-Coated Dimict Breccia": "These dimict rocks consist primarily of a dark-colored impact-melt lithology containing a variety of mineral clasts, rock fragments and fragmental breccias, and a light-colored cataclastic anorthosite lithology.",
	"Regolith Breccia": "It is comprised of fragments of other rocks. Regolith consists of pieces of the lunar crust that have been pummeled and broken down by billions of years of impacts caused by everything from large asteroids to the smallest of cosmic dust particles and even solar wind.",
	"Granitic Breccia": "This large Moon rock has abundant clasts of other rock fragments mixed into two dominant lithologies. One lithology is more blackish in color, the other lithology is a mix of a white and gray ."
}

var is_player_near: bool = false

func _ready() -> void:
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
