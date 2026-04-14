extends Control
# Splash Screen - Shows game title and "Press any key" message

# Reference to the flashing text label
@onready var press_key_label = $VBoxContainer/PressKeyLabel
@onready var video_player = $Background
@onready var animation_player = $Transition/AnimationPlayer

# Flashing animation variables
var flash_speed: float = 2.0  # Speed of the flash (higher = faster)
var time_passed: float = 0.0

# Load the sound effect
var key_press_sfx = preload("res://assets/audio/sfx/Dark Souls 2 Start Menu Sound Effect.wav")

func _ready():
	# Make sure we can receive input
	set_process_input(true)
	video_player.play()

func _process(delta):
	# Animate the "Press any key" text - fades in and out
	time_passed += delta * flash_speed
	var alpha = (sin(time_passed) + 1.0) / 2.0  # Oscillates between 0 and 1
	press_key_label.modulate.a = alpha

func _input(event):
	# Check if any key, mouse button, or controller button is pressed
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_pressed():
			# Play sound effect
			AudioManager.play_sfx(key_press_sfx)
			# Fade to menu
			fade_to_menu()

func fade_to_menu():
	# Play fade to black animation
	animation_player.play("fade_to_black")
	# Wait for animation to finish
	await animation_player.animation_finished
	# Then go to menu
	GameManager.goto_main_menu()
