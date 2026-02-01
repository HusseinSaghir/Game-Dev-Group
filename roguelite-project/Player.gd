extends CharacterBody2D

#Below we have Godot spevific annotations which we will be seeing often
#@export makes a variable editable within the godot inspector on the right -> 
#Great tool for debugging and testing fast!
#@onready is a little more complicated but essentially this gets reference to a node when the scene is ready
#So our animated sprite is only initializes when the speed var is checked

#NOTE: Godot scripting language is very different. You do not need to use brackets at all.
#Instead things must line up with indentations to work such as lining up if else statements

# To quick save in Godot it is 
# Ctrl + S / Cmd + S - Save current scene
# Ctrl + Shift + S / Cmd + Shift + S - Save All scenes
# Also it auto saves after each run attempt!

#Movement variables
@export var speed: float = 100.0

# Animation node reference
@onready var animated_sprite = $AnimatedSprite2D

#Stores last direction for our idle animations
var last_direction: Vector2 = Vector2.DOWN


func _ready():
	#Play initial idle animation
	animated_sprite.play("idle_down")


func _physics_process(_delta):
		 # DEBUG - Check if input is working
		 # Godot has built in preset commands but I did these myself
		 # To do so go to Project -> Project Settings -> Input mapping
	print("W: ", Input.is_action_pressed("move_up"))
	print("A: ", Input.is_action_pressed("move_left"))
	print("S: ", Input.is_action_pressed("move_down"))
	print("D: ", Input.is_action_pressed("move_right"))
	
	
	#Get input directions for WASD and Arrow keys
	var input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
		
	)

	#Normalizing diagonal movement d
	#We do this in order to make sure diagonal speed is not faster than normal left right speeds
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		last_direction = input_direction

	#Sets velocity
	velocity = input_direction * speed

	#Handles animations for movement
	update_animation(input_direction)

	#Move the character
	#This is really cool because we don't have to set specific vector params
	move_and_slide()


func update_animation(direction: Vector2):
	if direction.length() == 0:
		# Idle - uses last direction
		play_idle_animation()
	else:
		#Moving - determines direction
		play_movement_animation(direction)


func play_movement_animation(direction: Vector2):
	#Determines our primary direction 
	#We set it to prioritize horizontal over vertical diagonals
	if abs(direction.x) > abs(direction.y):
		# Moving horizontally
		if direction.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		# Moving vertically
		if direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")


func play_idle_animation():
	#plays idle animation if we decide to have any
	#currently based on our last direction
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			animated_sprite.play("idle_right")
		else:
			animated_sprite.play("idle_left")
	else:
		if last_direction.y > 0:
			animated_sprite.play("idle_down")
		else:
			animated_sprite.play("idle_up")
