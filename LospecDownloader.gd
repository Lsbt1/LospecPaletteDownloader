extends HTTPRequest
class_name LospecDownloaderApi

# This file is created with the intent of downloading lospec pallets to use in your projects without downloading them to the local machine

# Lospec uses a very simple id system (with some rules)
# https://lospec.com/palette-list/(pallet-name).(format)

# Saves all the lospec files it downloads into the lospec dir (user://lospec_api)
# TODO : After a session it deletes them all or manually with 'flush()' 

# At this point there is no way to list the lospec pallets from source but i am sure i will figure it out.

# NOTE: if the pallet has numbers that start with 0 eg. 02 it wont work

signal download_started()
signal download_completed()
signal file_loaded_into_memory(memory_index)

# Array of strings
var memory = []

enum Formats {
	PNG1, PNG8, PNG32, PAL, JASC, ASE, TXT, GPL, HEX
}

export var palette_name = ""
export(Formats) var format = 0
var url = ""
var downloading = false

# Depricated soon
var downloaded_bytes = -1
var download_size = -1

var extensions = {
	Formats.PNG1: "-1x.png",
	Formats.PNG8: "-8x.png",
	Formats.PNG32: "-32x.png",
	Formats.PAL: ".pal",
	Formats.ASE: ".ase",
	Formats.TXT: ".txt",
	Formats.GPL: ".gpl",
	Formats.HEX: ".hex",
}

func _ready() -> void:
	connect("request_completed", self, "lospec_request_completed")
		
# Only call if needed, will update before download begins
func update_download_link() -> void:
	# To add rules use 'format_link()'
	var _palette_name : String = format_link(palette_name)
	print(_palette_name)
	
	url = "https://lospec.com/palette-list/" + _palette_name + extensions[format]
	print(url)
	
func download() -> void:
	update_download_link()
	var file_path = "user://" + palette_name + extensions[format]
	
	set_download_file(file_path)
	
	if request(url) == OK:
		downloading = true
	else:
		print("Cannot retrive the file, it the name correct?")
	
func lospec_request_completed(result : int, respones_code : int, _headers : PoolStringArray, _body : PoolByteArray) -> void:
	downloading = false
	emit_signal("download_completed")
	print("File downloaded ", result, ", ", respones_code)
	
	# Load file into memory
	memory.append(
		"user://" + palette_name + extensions[format]
	)
	
	emit_signal("file_loaded_into_memory", memory.size() - 1)

func get_memory(memory_inedx : int) -> String:
	return memory[memory_inedx]
	
func format_link(base_text : String) -> String:
# Todo : implement a better solution for this
	var _string : String = base_text
	_string.to_lower()
	_string = _string.replace(" - ", "-")
	_string = _string.replace(" ", "-")
	_string = _string.replace(".", "")
	return _string
