extends Area2D

#Script for checking if the enemy hits the hitbox
@onready var audio = $"../../AudioStreamPlayer2D"

const HIT_SOUND = preload("res://assets/audio/sfx/bonk-4.wav")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Play a test audio on collision
func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and !get_parent().iframes:
		print_debug("[HitDetector] Hit by Enemy '", body.name, "' for ", body.damage, " dmg")
		AudioManager.play_sfx(HIT_SOUND)
		get_parent().take_damage(body.damage)
		if get_parent().has_method("trigger_iframes"):
			get_parent().trigger_iframes()
	else:
		print_debug("[HitDetector] Body entered (ignored): ", body.name)
