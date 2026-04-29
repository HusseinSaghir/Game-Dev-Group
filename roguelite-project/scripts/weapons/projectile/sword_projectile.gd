extends Node2D

#Speed of the Bullet
const SPEED: int = 300


#Made so it can store a reference from the weapon its tide to
#Which in this case its the MeleeWeapon
var weapon_ref : MeleeWeapon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

#Whenever the Cat Bullet collides with another hitbox
func _on_body_entered(body: Node2D) -> void:
	#This is for if the player runs into the bullet the bullet will not disapear
	if body.is_in_group("Player"):
		return
	if body.is_in_group("Enemy"):
		print(weapon_ref.detect_hits())
		if body.has_method("take_damage"):
			body.take_damage(weapon_ref.detect_hits())
		queue_free()
	else:
		queue_free()

#When the Cat Bullet goes out of the camera view it removes the instance
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
