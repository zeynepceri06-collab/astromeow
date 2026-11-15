extends Node

signal stats_updated
signal game_over(won: bool, reason: String)

signal nasa_flare_loaded

# --- NASA API VERİLERİ ---
var flare_data = {
	"class_type": "M2.4",
	"time": "2026-11-14 14:22 UTC",
	"location": "N18W42 (Active Region 3889)",
	"is_live": false
}

signal rock_hovered(info_text: String)

# Phase 1: Optional Ship Prep Tasks (+30s each)
var tasks = {
	"polyethylene": false,
	"space_food": false,
	"mli": false
}

# Phase 2: Dynamic 5-Rock Mission Targets
var all_rock_types = ["Basalt", "Anorthosite", "Breccia", "Regolith", "Ilmenite", "Olivine"]
const ROCK_DESCRIPTIONS = {
	"Basalt": "(iron & magnesium)",
	"Anorthosite": "Bright white highland",
	"Breccia": "Jagged rock fragments",
	"Regolith": "Fine, powdery lunar dust",
	"Ilmenite": "Titanium-iron oxide",
	"Olivine": "Greenish magnesium-iron crystal"
}
var target_rocks: Dictionary = {}
var collected_rocks: Dictionary = {}

var time_left: float = 60.0 # Base 1 minute for the Moon phase
var is_timer_running: bool = false
var current_phase: String = "SHIP"

func _ready() -> void:
	generate_random_targets()
	fetch_nasa_solar_flare()

func generate_random_targets() -> void:
	target_rocks.clear()
	collected_rocks.clear()
	for i in range(5):
		var chosen = all_rock_types.pick_random()
		target_rocks[chosen] = target_rocks.get(chosen, 0) + 1
		collected_rocks[chosen] = 0

	

var api_key: String = Secrets.NASA_API_KEY.strip_edges()

func fetch_nasa_solar_flare() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_nasa_request_completed)
	
	# Son 30 günün gerçek Güneş patlamalarını çek (kesin veri gelmesi için)
	var unix_now = Time.get_unix_time_from_system()
	var end_date = Time.get_date_string_from_unix_time(unix_now)
	var start_date = Time.get_date_string_from_unix_time(unix_now - 30 * 86400)
	
	var url = "https://api.nasa.gov/DONKI/FLR?startDate=%s&endDate=%s&api_key=%s" % [start_date, end_date, api_key]
	print("[NASA API] URL: ", url.replace(api_key, "***"))
	http.request(url)

func _on_nasa_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var raw_text = body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[NASA API] Yanıt alınamadı (Kod: %d) -> Detay: %s" % [response_code, raw_text])
		return
		
	var json = JSON.parse_string(raw_text)
	if typeof(json) == TYPE_ARRAY and json.size() > 0:
		var latest = json[json.size() - 1]
		
		flare_data["class_type"] = str(latest.get("classType", "M1.8"))
		var raw_time = str(latest.get("peakTime", latest.get("beginTime", "")))
		flare_data["time"] = raw_time.replace("T", " ").replace("Z", " UTC")
		
		var loc = str(latest.get("sourceLocation", ""))
		var region = str(latest.get("activeRegionNum", ""))
		if loc != "":
			flare_data["location"] = "%s (AR %s)" % [loc, region] if region != "" else loc
		else:
			flare_data["location"] = "Solar Disk (Active Region %s)" % region
			
		flare_data["is_live"] = true
		emit_signal("nasa_flare_loaded")
		print("[NASA LIVE DONKI] Güneş Patlaması Yüklendi: ", flare_data)
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
	var won = true
	for rock in target_rocks:
		if collected_rocks[rock] < target_rocks[rock]:
			won = false
			break
	if won:
		current_phase = "FLIGHT_RETURN"
		emit_signal("stats_updated")
		var main_scene = get_tree().current_scene
		if main_scene.has_method("load_space_flight"):
			main_scene.load_space_flight("RETURN")
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
