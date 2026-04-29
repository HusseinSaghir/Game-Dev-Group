extends StaticBody2D
class_name TroomDoor

const KEY_RESOURCE = preload("res://scripts/items/Resources/pickup/resource_key.tres")
@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.connect("body_entered", _on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if not body.is_in_group("Player"):
		return
	var inventory = body.find_child("Inventory")
	if not inventory:
		return
	if inventory.remove_resrouces("Key", 1) == "passed":
		get_node("CollisionShape2D").queue_free()
