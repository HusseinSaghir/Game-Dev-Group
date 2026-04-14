extends Panel
# Settings Menu - Audio controls and resolution options

# References to UI elements
@onready var music_slider = $VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider = $VBoxContainer/SFXRow/SFXSlider
@onready var resolution_dropdown = $VBoxContainer/ResolutionDropdown
@onready var close_button = $VBoxContainer/CloseButton

# Common resolution options
const RESOLUTIONS = {
	"1920x1080": Vector2i(1920, 1080),
	"1600x900": Vector2i(1600, 900),
	"1366x768": Vector2i(1366, 768),
	"1280x720": Vector2i(1280, 720),
	"1024x576": Vector2i(1024, 576),
}

func _ready():
	# Setup resolution dropdown
	setup_resolution_dropdown()
	
	# Set slider values from AudioManager
	music_slider.value = AudioManager.music_volume
	sfx_slider.value = AudioManager.sfx_volume
	
	# Connect signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	resolution_dropdown.item_selected.connect(_on_resolution_selected)
	close_button.pressed.connect(_on_close_pressed)

# Populate the resolution dropdown with options
func setup_resolution_dropdown():
	resolution_dropdown.clear()
	var index = 0
	var current_size = DisplayServer.window_get_size()
	
	for res_name in RESOLUTIONS:
		resolution_dropdown.add_item(res_name)
		# Select current resolution if it matches
		if RESOLUTIONS[res_name] == current_size:
			resolution_dropdown.select(index)
		index += 1

# Music slider changed
func _on_music_slider_changed(value: float):
	AudioManager.set_music_volume(value)

# SFX slider changed
func _on_sfx_slider_changed(value: float):
	AudioManager.set_sfx_volume(value)

# Resolution dropdown changed
func _on_resolution_selected(index: int):
	var res_name = resolution_dropdown.get_item_text(index)
	var new_size = RESOLUTIONS[res_name]
	DisplayServer.window_set_size(new_size)
	# Center the window
	var screen_size = DisplayServer.screen_get_size()
	var window_pos = (screen_size - new_size) / 2
	DisplayServer.window_set_position(window_pos)

# Close button clicked
func _on_close_pressed():
	hide()
