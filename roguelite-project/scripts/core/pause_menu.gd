extends CanvasLayer
# Pause Menu - Pauses game and provides options to resume, adjust settings, or quit

#Reference
@onready var settings_popup = $SettingsPopup


func _ready():
	hide()
	
	#Connecting the buttons here
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitMenuButton.pressed.connect(_on_quit_menu_pressed)
	$VBoxContainer/QuitToDesktopButton.pressed.connect(_on_quit_desktop_pressed)
	
	#Hide settings popup
	if settings_popup:
		settings_popup.hide()
		

func _input(event):
	# Toggle pause with ESC key
	if event.is_action_pressed("pause"):
		toggle_pause()
 
func toggle_pause():
	if visible:
		# Currently paused - resume
		resume_game()
	else:
		# Not paused - pause
		pause_game()
 
func pause_game():
	get_tree().paused = true
	show()
 
func resume_game():
	get_tree().paused = false
	hide()
	if settings_popup:
		settings_popup.hide()
 
# Resume button clicked
func _on_resume_pressed():
	resume_game()
 
# Settings button clicked
func _on_settings_pressed():
	if settings_popup:
		settings_popup.show()
 
# Quit to menu button clicked
func _on_quit_menu_pressed():
	# Unpause before changing scenes
	get_tree().paused = false
	GameManager.goto_main_menu()
 
# Quit to desktop button clicked
func _on_quit_desktop_pressed():
	GameManager.quit_game()
