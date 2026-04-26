extends EquipItem

@export var resource_type : Resource


#When the item is touched by the player the item will call change_damage() and change_speed() functions from the player script
#It will also print "picked up" for now as a test
#Then it will delete the item from the current scene
func _on_body_entered(body: Node2D) -> void:


	if not body.is_in_group("Player"):
		return

	body.change_speed(20)
	print("picked up")
	queue_free()

	
	#This will check to see if the body that interacted with the item has a Inventory Child
	#If it does have a inventory it will call the add_resources() function and add the resource to the inventory
	var inventory = body.find_child("Inventory")
	if(inventory):
		inventory.add_resources(resource_type, 1)
		print("picked up")
		queue_free()
