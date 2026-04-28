class_name WeaponShortbow
extends EquipItem
#This is the shortbow weapon
#This will shoot a shotgun like spread projectiles that do less damage



#Variables for the weapon
#Knockback variable if we do use it
@export var hit_force : float
#A range for how much we want the bullets to spread
@export_range(0, 360) var arc : float = 0
#The amount of bullets that will be with each shot
@export var bullet_count: int = 3
@onready var muzzle : Marker2D = $Marker2D

#Currently on standby
#@onready var anim : AnimationPlayer = $AnimationPlayer
#@onready var hit_box : Area2D = $Hitbox

const BULLET = preload("res://scenes/weapons/Projectile/shortbow_projectile.tscn")






# animation
# hit box
# For when the action "attack" is pressed and will cause 
func _use():
	#anim.play("attack")
	
	for i in bullet_count:
		var bullet_instance = BULLET.instantiate()
		bullet_instance.weapon_ref = self
		bullet_instance.position = muzzle.global_position
		var arc_rad = deg_to_rad(arc)
		var increment = arc_rad / (bullet_count - 1)
		bullet_instance.global_rotation = (
			global_rotation +
			increment * i -
			arc_rad / 2
		)
		get_tree().root.add_child(bullet_instance)

#Will call this function whenever the projectile tied to the weapon hits on contact with a enemy
func detect_hits():
	return owner_character.real_damage

#Whenever the weapon is picked up it will call this function to return the base dmg value of the weapon
func weapon_damage():
	return 20
