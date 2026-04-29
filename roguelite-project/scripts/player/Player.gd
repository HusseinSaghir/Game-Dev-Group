extends CharacterBody2D

class_name Player
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
# Match this to whichever physics layer number your enemies are on
@export var enemy_collision_layer: int = 2
#The real total damage variable for both weapon and items
var real_damage: int = 0
#The total damage from any item that was picked up
var applied_damage: int = 0
#Triggers I-Frames
var iframes: bool = false
#Animation node reference
@onready var animated_sprite = $AnimatedSprite2D
#Timer for the I-Frames
@onready var flicker_timer = $AnimatedSprite2D/FlickerTimer
#The Collision Body (hitbox)
@onready var collision = $CollisionShape2D
#Hitdetection reference
@onready var hitdetector = $Area2D  

#Stores last direction for our idle animations
var last_direction: Vector2 = Vector2.DOWN

# --- HUD Reference --- 
@export var player_hud: Node

# --- HEALTH ---
var max_health := 100 
var current_health := 100 

# --- STAMINA ---
var current_stamina := 100.0
var max_stamina := 100.0
var stamina_cost := 10.0
var stamina_regen := 20.0

func _ready():
	#Play initial idle animation
	animated_sprite.play("idle_down")
	
	


func _physics_process(_delta):
		 # DEBUG - Check if input is working
		 # Godot has built in preset commands but I did these myself
		 # To do so go to Project -> Project Settings -> Input mapping
	#print("W: ", Input.is_action_pressed("move_up"))
	#print("A: ", Input.is_action_pressed("move_left"))
	#print("S: ", Input.is_action_pressed("move_down"))
	#print("D: ", Input.is_action_pressed("move_right"))
	#print(real_damage)
	
	#Get input directions for WASD and Arrow keys
	var input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
		
	)

	#Normalizing diagonal movement 
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
	
	# --- STAMINA REGEN ---
	current_stamina += stamina_regen * _delta
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	# --- UPDATE HUD ---
	if player_hud: 
		player_hud.set_stamina(current_stamina)


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

#This function is called whenever a item is picked up that changes a damage value
func change_damage(amount: int):
	applied_damage += amount
	real_damage += amount


#This function is called whenever a tiem is picked up that changes a speed value
func change_speed(amount: int):
	speed += amount


#This function is called whenever a item is picked up that changes the max hp value
func change_health(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	
	if player_hud:
		player_hud.set_health(current_health)
	

#This function is called whenever a item is picked up that changes the max stam value
func change_stam(amount: int):
	current_stamina += amount
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	if player_hud:
		player_hud.set_stamina(current_stamina)

#This function is called whenever you change a weapon
#It will set the real_damage to 0  then get the damage value of the weapon that was picked up
#It will then add that and the applied_damage to real_damage
func change_weapon_damage(weapond: int):
	real_damage = 0
	real_damage = weapond
	real_damage += applied_damage
	
func trigger_iframes():
	iframes = true
	flicker_timer.start(1)
	hitdetector.set_deferred("monitoring", false)
	set_collision_mask_value(enemy_collision_layer, false)
	print_debug("[Player] I-frames ON — enemy collision layer ", enemy_collision_layer, " disabled")
	
	while iframes:
		animated_sprite.visible = !animated_sprite.visible
		await get_tree().create_timer(0.05).timeout
	
	animated_sprite.visible = true
	animated_sprite.modulate = Color.WHITE
	hitdetector.set_deferred("monitoring", true)
	set_collision_mask_value(enemy_collision_layer, true)
	print_debug("[Player] I-frames OFF — collision restored")

func _on_flicker_timer_timeout() -> void:
	iframes = false
	
# Currently we apply damage, this function take damage from enemy and apply to 
# player so we can end the game if we take too much damage
func take_damage(amount: float):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	print_debug("[Player] Took ", amount, " damage → Health: ", current_health, "/", max_health)
	
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1.0, 0.2, 0.2), 0.05)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.15)
	
	if player_hud:
		player_hud.on_damage_taken(current_health)
	
	if current_health <= 0:
		die()
		
# --- ATTACK (STAMINA USAGE) ---
func use_stamina_for_attack():
	if current_stamina < stamina_cost:
		print("Not enough stamina")
		return false
		
	current_stamina -= stamina_cost
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	if player_hud: 
		player_hud.set_stamina(current_stamina)
	
	return true
# Since we do not have an animation for die or a scene for gameover, 
# we would restart the level if player's health reaches 0. A
func die():
	get_tree().reload_current_scene()
