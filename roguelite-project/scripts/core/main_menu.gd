extends Control
# Main Menu - Entry point with Start, Settings, and Quit buttons

# Reference to settings popup (will be shown/hidden)
@onready var settings_popup = $SettingsPopup

func _ready():
	# Connect button signals to functions
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Make sure settings popup is hidden at start
	if settings_popup:
		settings_popup.hide()

	var music = load("res://assets/audio/music/Fortunes Delight Extended.mp3")
	AudioManager.play_music(music)

# Start Game button clicked
func _on_start_pressed():
	GameManager.goto_game()

# Settings button clicked
func _on_settings_pressed():
	if settings_popup:
		settings_popup.show()

# Quit button clicked
func _on_quit_pressed():
	GameManager.quit_game()
