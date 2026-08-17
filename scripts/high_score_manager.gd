extends Node


const SAVE_PATH := "user://high_score.save"

var record_lines: int = 0
var record_player: String = ""


func _ready() -> void:
	load_record()
	
		
func load_record() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file == null:
		return

	var data = file.get_var()
	file.close()
	
	if data is Dictionary:
		record_lines = data.get("record_lines", 0)
		record_player = data.get("record_player", "")
		
		
func save_record(player_name: String, lines: int) -> void:
	record_lines = lines
	record_player = player_name
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		return
		
	var data = {
		"record_player": record_player,
		"record_lines": record_lines
	}
	
	file.store_var(data)
	file.close()

	print("RECORD: " + str(data))
