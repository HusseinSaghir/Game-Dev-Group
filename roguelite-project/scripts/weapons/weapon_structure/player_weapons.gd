class_name PlayerWeapons
extends CharacterWeapons


#This will check everyframe for where the mouse position is on the players screen
func _process (_delta : float):
	var mouse_pos : Vector2 = get_global_mouse_position()
	var mouse_dir : Vector2 = global_position.direction_to(mouse_pos)
	
	
	#This will check if there is a current weapon equiped
	#If there is then it will point the weapon towards where the mouse is at
	#If there is no weapon equiped then it will skip over the if statement
	if current_weapon:
		current_weapon.set_aim_direction(mouse_dir)
		
		if Input.is_action_just_pressed("attack"):
			# Added to this code to drain stamina when using weapon
			var player = owner
			if player.current_stamina >= player.stamina_cost:
				player.current_stamina -= player.stamina_cost
				
				if player.player_hud:
					player.player_hud.set_stamina(player.current_stamina)
					
				current_weapon._try_use()
