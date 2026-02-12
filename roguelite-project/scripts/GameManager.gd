extends Node
# GameManager - Handles scene transitions and global game state
# This is an Autoload (singleton) - access from anywhere with: GameManager.goto_scene()

# Scene paths - update these to match your actual scene file paths
const SPLASH_SCENE = "res://scenes/screens/splash_screen.tscn"
const MAIN_MENU_SCENE = "res://scenes/screens/main_menu.tscn"
const GAME_SCENE = "res://scenes/screens/game_world.tscn"

# Current scene reference
var current_scene = null

func _ready():
	# Get the current scene when the game starts
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

# Change to a new scene (with optional fade effect)
func goto_scene(path: String):
	# Deferred call to avoid errors during physics processing
	call_deferred("_deferred_goto_scene", path)

# Internal function - don't call this directly
func _deferred_goto_scene(path: String):
	# Free the current scene
	if current_scene:
		current_scene.free()
	
	# Load the new scene
	var new_scene = load(path)
	if new_scene:
		current_scene = new_scene.instantiate()
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
	else:
		push_error("Failed to load scene: " + path)

# Convenience functions for common scene transitions
func goto_splash():
	goto_scene(SPLASH_SCENE)

func goto_main_menu():
	goto_scene(MAIN_MENU_SCENE)

func goto_game():
	goto_scene(GAME_SCENE)

# Quit the game
func quit_game():
	get_tree().quit()
