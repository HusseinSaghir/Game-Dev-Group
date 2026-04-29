extends EquipItem

@export var resource_type : Resource


#When the item is touched by the player the item will call change_damage() and change_speed() functions from the player script
#It will also print "picked up" for now as a test
#Then it will delete the item from the current scene
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	body.change_stam(10)
	
	var hud = get_tree().get_first_node_in_group("HUD")
	
	if hud:
		hud.add_item($Sprite2D.texture)
		
	queue_free()
