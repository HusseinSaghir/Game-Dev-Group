extends EquipItem

@export var type_weapon : PackedScene

#When the player touches this weapon it will unequip the old weapon and equip the new one
func _on_body_entered(body: Node2D) -> void:
	var wepchange = body.find_child("PlayerWeapons")
	
	if wepchange:
		wepchange.call_deferred("unequip_weapon")
		wepchange.call_deferred("equip_weapon", type_weapon)
	
	queue_free()
