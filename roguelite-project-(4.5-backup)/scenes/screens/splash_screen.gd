extends Control
# Splash Screen - Shows game title and "Press any key" message

# Reference to the flashing text label
@onready var press_key_label = $VBoxContainer/PressKeyLabel

# Flashing animation variables
var flash_speed: float = 2.0  # Speed of the flash (higher = faster)
var time_passed: float = 0.0

func _ready():
	# Make sure we can receive input
	set_process_input(true)

func _process(delta):
	# Animate the "Press any key" text - fades in and out
	time_passed += delta * flash_speed
	var alpha = (sin(time_passed) + 1.0) / 2.0  # Oscillates between 0 and 1
	press_key_label.modulate.a = alpha

func _input(event):
	# Check if any key, mouse button, or controller button is pressed
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_pressed():
			# Go to main menu
			GameManager.goto_main_menu()
