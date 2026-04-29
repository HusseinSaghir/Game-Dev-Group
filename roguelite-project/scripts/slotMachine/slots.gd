extends StaticBody2D
# Slot Machine - Takes 1 coin on contact, plays animation, gives random reward

# References to scene nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var spawn_point = $SpawnPoint
@onready var detector = $DetectionArea

# Preload reward pickups
const COIN_PICKUP = preload("res://scenes/items/pickups/pickup_coin.tscn")
const KEY_PICKUP = preload("res://scenes/items/pickups/pickup_key.tscn")

# State management
var is_spinning: bool = false

var insertCoinFX = load("res://assets/audio/sfx/slotFX/insertCoin.wav")
var spinFX = load("res://assets/audio/sfx/slotFX/spinFX.wav")
var winFX = load("res://assets/audio/sfx/slotFX/winFX.wav")
var loseFX = load("res://assets/audio/sfx/slotFX/loseFX.wav")


# Reward weights (you can adjust these percentages)
enum Reward { LOSE, WIN_1_COIN, WIN_3_COINS, WIN_KEY }
var reward_weights = {
	Reward.LOSE: 25,        # 25% chance to lose
	Reward.WIN_1_COIN: 10,  # 15% chance for 1 coin
	Reward.WIN_3_COINS: 25, # 10% chance for 3 coins
	Reward.WIN_KEY: 40      # 25% chance for key
}

func _ready():

	# Connect detection area signal
	if detector:
		detector.body_entered.connect(_on_body_entered)
	
	# Start with idle animation
	if animated_sprite:
		animated_sprite.play("idle")

func _on_first_sfx_finished():
	var audio_manager = get_node("/root/AudioManager")
	audio_manager.play_sfx_secondary()  # call a method on AudioManager to play the second SFX


func _on_body_entered(body: Node2D):
	# Auto-activate when player touches (only if not already spinning)
	if body.is_in_group("Player") and not is_spinning:
		attempt_spin(body)

# Attempt to use the slot machine
func attempt_spin(player_body: Node2D):
	var inventory = player_body.find_child("Inventory")
	if not inventory:
		print("No inventory found!")
		return
	
	# Try to remove 1 coin from inventory
	var result = inventory.remove_resrouces("Coin", 1)
	
	if result == "passed":
		# Successfully took coin - start spinning!
		start_spin()
		AudioManager.play_sfx_chain(insertCoinFX, spinFX)

	else:
		print("Not enough coins!")
		# Optional: play "not enough coins" sound or animation

# Start the slot machine spin
func start_spin():
	is_spinning = true
	
	# Play spinning animation
	if animated_sprite:
		animated_sprite.play("spinning")
	
	# Wait for spin duration (2-3 seconds)
	await get_tree().create_timer(2.5).timeout
	
	# Determine reward
	var reward = get_random_reward()
	
	# Play win or lose animation based on result
	if reward == Reward.LOSE:
		if animated_sprite:
			animated_sprite.play("lose")
		AudioManager.play_sfx(loseFX)
		print("You lost!")
	else:
		if animated_sprite:
			animated_sprite.play("win")
		AudioManager.play_sfx(winFX)
	await get_tree().create_timer(1.5).timeout  # Wait 1.5 seconds
	spawn_reward(reward)
	
	# Wait for win/lose animation to finish
	await get_tree().create_timer(3.0).timeout
	
	# Return to idle
	if animated_sprite:
		animated_sprite.play("idle")
	
	is_spinning = false

# Get random reward based on weights
func get_random_reward() -> Reward:
	var total_weight = 0
	for weight in reward_weights.values():
		total_weight += weight
	
	var random_value = randi() % total_weight
	var current_sum = 0
	
	for reward in reward_weights:
		current_sum += reward_weights[reward]
		if random_value < current_sum:
			return reward
	
	return Reward.LOSE  # Fallback

# Spawn the reward pickup
func spawn_reward(reward: Reward):
	match reward:
		Reward.WIN_1_COIN:
			print("You won 1 coin!")
			spawn_coins(1)
		Reward.WIN_3_COINS:
			print("You won 3 coins!")
			spawn_coins(3)
		Reward.WIN_KEY:
			print("You won a key!")
			spawn_key()

# Spawn coin pickups
func spawn_coins(count: int):
	for i in range(count):
		var coin = COIN_PICKUP.instantiate()
		get_parent().add_child(coin)
		
		# Position coins in front of machine with slight offset
		var offset = Vector2(randf_range(-15, 15), randf_range(-10, 10))
		if spawn_point:
			coin.global_position = spawn_point.global_position + offset
		else:
			coin.global_position = global_position + Vector2(0, 30) + offset

# Spawn key pickup
func spawn_key():
	var key = KEY_PICKUP.instantiate()
	get_parent().add_child(key)
	
	# Position key in front of machine
	if spawn_point:
		key.global_position = spawn_point.global_position
	else:
		key.global_position = global_position + Vector2(0, 30)
