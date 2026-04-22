extends Node

#This is purly for testing purposes and wil have a small change log
#Current Log
#This test is set up for seeing when I interact with it if it will remove a key


func _on_testdummy_body_entered(body: Node2D) -> void:
	var inventory = body.find_child("Inventory")
	
	if(inventory):
		var worked = inventory.remove_resrouces("Coin", 1)
		print(worked)
