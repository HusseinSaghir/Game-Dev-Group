class_name CharacterWeapons
extends Node2D

@export var weapon_to_equip : PackedScene

var current_weapon : EquipItem

@onready var player : CharacterBody2D = $".."

#If there is a weapon equiped to the main character at the start it will equip said weapon.
func _ready():
	if weapon_to_equip:
		equip_weapon(weapon_to_equip)

#This method is called whenever a weapon is picked up by the character
#It will call the uneqiup_waepon() function to unequip a weapon if there is currently one equiped
func equip_weapon (weapon_scene : PackedScene):
	if current_weapon:
		unequip_weapon()
	
	current_weapon = weapon_scene.instantiate()
	add_child(current_weapon)
	current_weapon.global_position = global_position
	
	current_weapon.owner_character = player
	current_weapon._equip()

#This function will check to see if there is no current weapon equiped if there is none equiped it will exit the function. 
#If there is a weapon then it will call the _unequip() function from the equip_item script for any sound effects or other things that we want
#It will then remove the weapon from the scene
func unequip_weapon():
	if not current_weapon:
		return
	
	current_weapon._unequip()
	current_weapon.queue_free()
