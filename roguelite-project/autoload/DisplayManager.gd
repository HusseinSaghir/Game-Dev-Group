extends Node
# DisplayManager - Handles display settings (resolution, fullscreen, etc.)
# This is an Autoload (singleton) - access from anywhere with: DisplayManager.set_resolution()

# Current resolution
var current_resolution: Vector2i = Vector2i(1920, 1080)

func _ready():
	# Load saved display settings
	load_display_settings()

# Load display settings from file
func load_display_settings():
	var config = ConfigFile.new()
	var err = config.load("user://display_settings.cfg")
	
	if err == OK:
		current_resolution = config.get_value("display", "resolution", Vector2i(1920, 1080))
	else:
		# No config file exists - use defaults
		current_resolution = Vector2i(1920, 1080)
	
	# Apply loaded resolution
	apply_resolution()

# Apply the current resolution to the window
func apply_resolution():
	DisplayServer.window_set_size(current_resolution)
	
	# Center window on current screen
	var current_screen = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(current_screen)
	var screen_position = DisplayServer.screen_get_position(current_screen)
	var window_pos = screen_position + (screen_size - current_resolution) / 2
	DisplayServer.window_set_position(window_pos)

# Set resolution and save it
func set_resolution(resolution: Vector2i):
	current_resolution = resolution
	apply_resolution()
	save_display_settings()

# Save display settings to file
func save_display_settings():
	var config = ConfigFile.new()
	config.set_value("display", "resolution", current_resolution)
	config.save("user://display_settings.cfg")
