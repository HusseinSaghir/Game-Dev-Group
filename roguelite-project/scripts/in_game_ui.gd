extends Control

# UI NODE REFERENCES 
@onready var health_bar = $MarginContainer/VBoxContainer/HealthContainer/HealthBar
@onready var health_fx = $MarginContainer/VBoxContainer/HealthContainer/HealthFX
@onready var stamina_bar = $MarginContainer/VBoxContainer/StaminaContainer/StaminaBar
@onready var stamina_fx = $MarginContainer/VBoxContainer/StaminaContainer/StaminaFX

# Exported frames to use from inspector, this is easier if we want to change the UI later 
@export var health_frames: Array[Texture2D]
@export var stamina_frames: Array[Texture2D]

# PLAYER STATS, change if needed 
var max_health = 100 
var current_health = 100 
var max_stamina = 100 
var current_stamina = 100 

# HEALTH FX STATE 
var health_current = 0
var health_timer = 0.0
var health_speed = 0.1 
var health_playing = false

# STAMINA FX STATE 
var stamina_current = 0
var stamina_timer = 0.0 
var stamina_speed = 0.1
var stamina_playing = false

# TAKE DAMAGE FUNCTION, this will can be changed to how much we actually want the player -
# should take damage per hit. This also after we make our character detects hits from enemies.
func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	play_health_fx()

# Function to play health animation 
func play_health_fx():
	if health_frames.is_empty():
		return 
	
	health_playing = true 
	health_current = 0 
	health_timer = 0
	health_fx.texture = health_frames[0]
	
# Stamina FX, same deal as the play_health_fx. This can 
func play_stamina_fx():
	if stamina_frames.is_empty():
		return
	stamina_playing = true 
	stamina_current = 0
	stamina_timer = 0
	stamina_fx.texture = stamina_frames[0]

func use_stamina(amount): 
	current_stamina -= amount
	current_stamina = clamp(current_stamina, 0, max_stamina)
	stamina_bar.value = current_stamina
	play_stamina_fx()
	
# This function is for regenerating stamina 
func regen_stamina(delta):
	if current_stamina < max_stamina:
		current_stamina += 20 * delta
		current_stamina = clamp(current_stamina, 0, max_stamina)
		stamina_bar.value = current_stamina


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.value = current_health
	stamina_bar.value = current_stamina


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# HEALTH FX ANIMATION 
	if health_playing:
		health_timer += delta
		if health_timer >= health_speed:
			health_timer = 0 
			health_current += 1
			if health_current >= health_frames.size():
				health_playing = false
				health_current = 0 
				health_fx.texture = null
			else:
				health_fx.texture = health_frames[health_current]
				
	# STAMINA FX ANIMATION 
	if stamina_playing:
		stamina_timer += delta
		if stamina_timer >= stamina_speed:
			stamina_timer = 0 
			stamina_current += 1
			if stamina_current >= stamina_frames.size():
				stamina_playing = false
				stamina_current = 0
				stamina_fx.texture = null
			else: 
				stamina_fx.texture = stamina_frames[stamina_current]
