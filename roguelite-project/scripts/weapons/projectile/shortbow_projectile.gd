extends Node2D
#This projectile is for the shortbow
#One of the starter weps with a slower speed projectile but higher damage

const SPEED: int = 100

var player = "res://scenes/player/player.tscn"

var weapon_ref : WeaponShortbow

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

#Whenever the projectile has a collision this function will be called
func _on_body_entered(body: Node2D) -> void:
	#This is for if the player runs into the bullet the bullet will not disapear
	if body.is_in_group("Player"):
		return
	print(weapon_ref.detect_hits())
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
