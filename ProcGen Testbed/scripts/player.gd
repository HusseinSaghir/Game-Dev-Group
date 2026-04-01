extends CharacterBody2D
class_name Player

const SPEED = 75.0

var is_mining: bool = false
var hitbox_offset: Vector2
var last_direction: Vector2 = Vector2.RIGHT
var detected_rocks: Array = []
var pickaxeStrength: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickaxeHitbox: Area2D = $Hitbox
@onready var pickaxeCollisionShape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var miningTimer: Timer = $MiningTimer


func _ready() -> void:
	hitbox_offset = pickaxeHitbox.position #Initialize hitbox offset

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("usePickaxe") and miningTimer.is_stopped():
		usePickaxe()
	
	if is_mining:
		velocity = Vector2.ZERO
		return
	
	process_movement()
	process_animation()
	move_and_slide()
#------------------------------------------------------------------
#MOVEMENT AND ANIMATIONS
#------------------------------------------------------------------
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration..
	var direction := Input.get_vector("left", "right", "up", "down")
	
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		updateHitboxPosition()
	else:
		velocity = Vector2.ZERO
		
func process_animation() -> void:
	#Disable hitbox until player swings pickaxe.
	pickaxeHitbox.monitoring = false
	
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)
		
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.play(prefix + "_right")
	elif dir.y < 0:
		sprite.play(prefix + "_up")
	elif dir.y > 0:
		sprite.play(prefix + "_down")

#------------------------------------------------------------------
#HITBOX OFFSET
#------------------------------------------------------------------
func updateHitboxPosition() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			pickaxeHitbox.position = Vector2(-x, y)
			pickaxeCollisionShape.rotation_degrees = 0
		Vector2.RIGHT:
			pickaxeHitbox.position = Vector2(x, y)
			pickaxeCollisionShape.rotation_degrees = 0
		Vector2.UP:
			pickaxeHitbox.position = Vector2(y, -x)
			pickaxeCollisionShape.rotation_degrees = 90
		Vector2.DOWN:
			pickaxeHitbox.position = Vector2(y, x) 
			pickaxeCollisionShape.rotation_degrees = 90
#------------------------------------------------------------------
#MINING
#------------------------------------------------------------------
func usePickaxe() -> void:
	detected_rocks.clear()
	is_mining = true
	pickaxeHitbox.monitoring = true
	miningTimer.start()
	play_animation("mine", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_mining:
		is_mining = false
		if detected_rocks.size() > 0:
			var rock_to_hit = getMostOverlappingRock()
			rock_to_hit.takeDamage(pickaxeStrength)

func getMostOverlappingRock() -> Rock:
	var bestRock = detected_rocks[0]
	var bestDistance = pickaxeHitbox.global_position.distance_to(bestRock.global_position)

	for rock in detected_rocks:
		var distance = pickaxeHitbox.global_position.distance_to(rock.global_position)
		if distance < bestDistance:
			bestDistance = distance
			bestRock = rock
	
	return bestRock
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Rock:
		detected_rocks.append(body)
		

func add_ore(data: OreData) -> bool:
	return true
