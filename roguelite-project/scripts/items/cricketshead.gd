extends EquipItem


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#When the item is touched by the player the item will call change_damage() and change_speed() functions from the player script
#It will also print "picked up" for now as a test
#Then it will delete the item from the current scene
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	
	body.change_damage(-50)
	body.change_speed(500)
	
	print("picked up")
	queue_free()
