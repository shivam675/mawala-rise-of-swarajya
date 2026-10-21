extends Node

const SAVE_PATH: String = "user://first_oath.json"
var stages: Array = []
var stage: int = 0
var game: Node
var supplies: bool = false
var last_save_error: String = ""

func _ready() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/first_oath.json"))
	stages = data.stages

func current() -> Dictionary:
	return stages[stage]

func reset() -> void:
	stage = 0
	supplies = false

func advance(event: String) -> bool:
	if stage>=stages.size()-1 or current().event != event:
		return false
	if event == "supplies":
		supplies = true
	stage += 1
	return true

func restore(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if data.get("version") != 1 or not data.has("stage"):
		return false
	var value: Variant = data.stage
	if not (value is int or value is float):
		return false
	if not is_finite(float(value)) or float(value) != floorf(float(value)) or value<0 or value>=stages.size():
		return false
	stage = int(value)
	supplies = stage>=2 and stage<8
	return true

func save_progress() -> bool:
	last_save_error = ""
	var file := FileAccess.open(SAVE_PATH+".tmp",FileAccess.WRITE)
	if file == null:
		last_save_error = "Progress could not be saved on this device."
		return false
	file.store_string(JSON.stringify({"version":1,"stage":stage}))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		last_save_error = "Progress could not be saved on this device."
		return false
	var rename_error: Error = DirAccess.rename_absolute(SAVE_PATH+".tmp",SAVE_PATH)
	if rename_error != OK:
		last_save_error = "Progress could not be saved on this device."
		return false
	return true

func load_progress() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file == null:
		return false
	return restore(JSON.parse_string(file.get_as_text()))

func checkpoint() -> Vector2:
	if stage<=2:
		return Vector2(10,40)
	if stage==3:
		return Vector2(10,21)
	if stage<=5:
		return Vector2(-5.7,-27)
	if stage==6:
		return Vector2(-7.4,-71)
	return Vector2(0,-92)
