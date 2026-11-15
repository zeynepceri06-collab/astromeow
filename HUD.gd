extends CanvasLayer

@onready var timer_label = $TimerLabel
@onready var checklist_label = $ChecklistLabel
@onready var end_panel = $EndPanel
@onready var end_message = $EndPanel/EndMessage
@onready var rock_info_label = $RockInfoLabel
@onready var play_again_button = $EndPanel/PlayAgainButton

func _ready() -> void:
	end_panel.visible = false
	rock_info_label.visible = false
	GameManager.stats_updated.connect(update_ui)
	GameManager.game_over.connect(show_end_screen)
	GameManager.rock_hovered.connect(show_rock_info)
	play_again_button.pressed.connect(_on_play_again_pressed)
	update_ui()

func show_rock_info(info_text: String) -> void:
	if info_text == "":
		rock_info_label.visible = false
	else:
		rock_info_label.text = info_text
		rock_info_label.visible = true

func update_ui() -> void:
	if GameManager.current_phase == "SHIP":
		timer_label.text = "Moon Mission Time Ready: %.0fs (+30s per task)" % GameManager.time_left
		var t = GameManager.tasks
		checklist_label.text = "OPTIONAL PREP (+30s EACH):\n"
		checklist_label.text += "[%s] Polyethylene Radiation Bricks\n" % ("X" if t["polyethylene"] else " ")
		checklist_label.text += "[%s] Pack Space Cat Food\n" % ("X" if t["space_food"] else " ")
		checklist_label.text += "[%s] Assemble MLI Shielding\n" % ("X" if t["mli"] else " ")
		checklist_label.text += "\n>> COCKPIT READY: PRESS E TO LAUNCH <<"
	else:
		timer_label.text = "Lunar Time Left: %.1fs" % GameManager.time_left
		checklist_label.text = "COLLECT 5 TARGET SAMPLES:\n"
		for rock_type in GameManager.target_rocks.keys():
			var have = GameManager.collected_rocks.get(rock_type, 0)
			var need = GameManager.target_rocks[rock_type]
			var mark = "X" if have >= need else " "
			var desc = GameManager.ROCK_DESCRIPTIONS.get(rock_type, rock_type)
			checklist_label.text += "[%s] %s (%d/%d)\n" % [mark, desc, have, need]

func show_end_screen(won: bool, reason: String) -> void:
	rock_info_label.visible = false
	end_panel.visible = true
	end_message.text = ("VICTORY!\n" if won else "MISSION LOST:\n") + reason
	get_tree().paused = true

func _on_play_again_pressed() -> void:
	get_tree().paused = false
	end_panel.visible = false
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Main.tscn")
