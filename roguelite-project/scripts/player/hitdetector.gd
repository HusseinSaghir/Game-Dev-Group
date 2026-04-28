extends Area2D

#Script for checking if the enemy hits the hitbox
@onready var audio = $"../../AudioStreamPlayer2D"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Play a test audio on collision
func _on_body_entered(body: Node2D) -> void:
	print("Collided with: ", body.name)
	if body.is_in_group("Enemy") and !get_parent().iframes:
		audio.play()
		get_parent().take_damage(body.damage) # this to take damage if collide with enemy 
		if get_parent().has_method("trigger_iframes"):
			get_parent().trigger_iframes()
