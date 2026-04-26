extends Node2D

#This is purly for testing purposes and wil have a small change log
#Current Log
#This test is set up for seeing when I interact with it if it will remove a key




func _on_body_entered(body: Node2D) -> void:
	
	var inventory = body.find_child("Inventory")
	
	if(inventory):
		var worked = inventory.remove_resrouces("Key", 1)
		
		if(worked == "passed"):
			print("open")
			queue_free()
		else:
			print("Don't have the key required")
