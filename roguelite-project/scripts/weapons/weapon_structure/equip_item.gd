class_name EquipItem
extends Node2D

#Variables used for weapons
@export var use_rate : float = 0.5
var last_use_time : float
var aim_angle : float
var owner_character : CharacterBody2D
var can_use : bool = true


#Used for rotating our weapons
#Gets Called every frame
func _process (delta: float):
	
	global_rotation = lerp_angle(global_rotation, aim_angle, 40 * delta)

#Used to point the weapon in the desired direction
#In the players case it will be the mouse
func set_aim_direction (aim_dir : Vector2):
	aim_angle = aim_dir.angle()

#These 2 funcions are temporary for right now
#Will be used for sound effects if we wanted them
func _equip ():
	owner_character.change_weapon_damage(weapon_damage())
	

func _unequip():
	pass
	
	

#Checks to see if the weapon can be used by the player or enemy based on the use rate
func _try_use () -> bool:
	if not can_use:
		return false
	
	if Time.get_unix_time_from_system() - last_use_time < use_rate:
		return false
	
	last_use_time = Time.get_unix_time_from_system()
	_use()
	
	return true

#This funciton will be for activating the weapon
func _use ():
	pass

func weapon_damage():
	pass
