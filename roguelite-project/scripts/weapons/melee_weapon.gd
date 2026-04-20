class_name MeleeWeapon
extends EquipItem

#Variables for the sub nodes for the weapon scene
#For knockback if we want it
@export var hit_force : float
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var muzzle : Marker2D = $Marker2D

const BULLET = preload("res://scenes/weapons/Projectile/cat_bullet.tscn")


# animation
# hit box
# For when the action "attack" is pressed and will cause 
func use():
	anim.play("attack")
	var bullet_instance = BULLET.instantiate()
	bullet_instance.weapon_ref = self
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation

#Will call this function whenever the projectile tied to the weapon hits on contact with a enemy
func detect_hits():
	return owner_character.real_damage

#Whenever the weapon is picked up it will call this function to return the base dmg value of the weapon
func weapon_damage():
	return 50
