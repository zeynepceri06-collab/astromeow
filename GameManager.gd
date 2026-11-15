extends Node

signal stats_updated
signal game_over(won: bool, reason: String)
signal rock_hovered(info_text: String)

# Phase 1: Optional Ship Prep Tasks (+30s each)
var tasks = {
	"polyethylene": false,
	"space_food": false,
	"mli": false
}

# Phase 2: Dynamic 5-Rock Mission Targets
var all_rock_types = ["HIGH TI BASALT", "Pyroclastic-glass Breccia", "Troctolite", "Shocked Norite", "Ferroan Anorthosite", "Glass-Coated Dimict Breccia", "Regolith Breccia", "Granitic Breccia"]
const ROCK_DESCRIPTIONS = {
	"HIGH TI BASALT": "Find a rock that endured a long period of cooling.",
	"Pyroclastic-glass Breccia": "Find a rock that is compacted glass deposit.",
	"Troctolite": "Find a rock that is gem-like.",
	"Shocked Norite": "Find a rock that is rich in magnesium.",
	"Ferroan Anorthosite": "Find a rock that formed the moon's first crust.",
	"Glass-Coated Dimict Breccia": "Find a rock that contains variety of mineral clasts.",
	"Regolith Breccia": "Find a rock that consists of pieces of lunar crust.",
	"Granitic Breccia": "Find a rock that is mixed of other fragments."
}
var target_rocks: Dictionary = {}
var collected_rocks: Dictionary = {}

var time_left: float = 60.0 # Base 1 minute for the Moon phase
var is_timer_running: bool = false
var current_phase: String = "SHIP"

func _ready() -> void:
	generate_random_targets()

func generate_random_targets() -> void:
	target_rocks.clear()
	collected_rocks.clear()
	
	for i in range(5):
		var chosen = all_rock_types.pick_random()
		target_rocks[chosen] = target_rocks.get(chosen, 0) + 1
		collected_rocks[chosen] = 0

func _process(delta: float) -> void:
	if current_phase == "MOON" and is_timer_running and time_left > 0:
		time_left -= delta
		emit_signal("stats_updated")
		if time_left <= 0:
			time_left = 0
			is_timer_running = false
			emit_signal("game_over", false, "Oxygen/Power depleted before all 5 samples were collected!")

func complete_task(task_name: String) -> void:
	if tasks.has(task_name) and not tasks[task_name]:
		tasks[task_name] = true
		time_left += 30.0 # +30 seconds bonus for Moon phase
		emit_signal("stats_updated")

func start_moon_phase() -> void:
	current_phase = "MOON"
	is_timer_running = true
	emit_signal("stats_updated")

func collect_rock(rock_type: String) -> void:
	if target_rocks.has(rock_type):
		collected_rocks[rock_type] += 1
		emit_signal("stats_updated")
		check_moon_win_condition()
	else:
		print("Not on the target list: ", rock_type)

func check_moon_win_condition() -> void:
	for rock_type in target_rocks.keys():
		if collected_rocks.get(rock_type, 0) < target_rocks[rock_type]:
			return
	
	is_timer_running = false
	emit_signal("game_over", true, "Mission Success! All 5 target lunar samples collected!")
	
func reset_game() -> void:
	tasks["polyethylene"] = false
	tasks["space_food"] = false
	tasks["mli"] = false
	time_left = 60.0
	is_timer_running = false
	current_phase = "SHIP"
	generate_random_targets()
	emit_signal("stats_updated")
