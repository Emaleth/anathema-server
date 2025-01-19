extends Node

var uuid : String
var data : Dictionary


func _on_timer_timeout() -> void:
	CharacterDatabase.data[uuid] = data
	CharacterDatabase.save_character_database()
