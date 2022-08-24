extends Control

onready var pallet_name_edit = $Margins/Content/DownloadInfo/PalletName
onready var extensions = $Margins/Content/DownloadInfo/Extensions
onready var download_btn = $Margins/Content/DownloadInfo/Download

onready var progress = $Margins/Content/Progress
onready var progress_data = $Margins/Content/ProgressData

onready var lospec_api = $LospecDownloaderApi

func _ready() -> void:
	for extension in lospec_api.extensions.keys():
		extensions.add_item(lospec_api.extensions[extension])

func lospec_file_loaded_into_memory(index : int) -> void:
	var memory = lospec_api.get_memory(index)
	
	var file = File.new()
	file.open(memory, File.READ)
	var bytes = file.get_buffer(file.get_len())
	
	if memory.get_extension() == "png":
		var image = Image.new()
		var data = image.load_png_from_buffer(bytes)
		var final_img = ImageTexture.new()
		final_img.create_from_image(image, 0)
		
		$Margins/Content/Viewport/DisplayTexture.texture = final_img
		$Margins/Content/Viewport/DisplayTexture.show()
		$Margins/Content/Viewport/TextDisplay.hide()
	else:
		$Margins/Content/Viewport/TextDisplay.text = file.get_as_text()
		$Margins/Content/Viewport/TextDisplay.show()
		$Margins/Content/Viewport/DisplayTexture.hide()
	
func _process(_delta: float) -> void:
	progress.value = lospec_api.downloaded_bytes
	progress.max_value = lospec_api.download_size
	progress_data.text = str(lospec_api.get_downloaded_bytes() * 100 / lospec_api.get_body_size(), " / 100 ")
	progress_data.text += " - " + lospec_api.url
	
	
	pallet_name_edit.editable = not lospec_api.downloading
	download_btn.disabled = lospec_api.downloading
	extensions.disabled = lospec_api.downloading
	
	
	

func PalletName_changed(new_text : String) -> void:
	lospec_api.palette_name = new_text
	
func PalletName_entered(new_text : String) -> void:
	lospec_api.palette_name = new_text
	pallet_name_edit.release_focus()

func extension_selected(index : int) -> void:
	lospec_api.format = index

func download_btn_pressed() -> void:
	lospec_api.download()
