extends Area2D

class_name Pickup

# Item type enumerator
enum ItemType { COIN, KEY }
@export var item_type: ItemType = ItemType.COIN

# Equip type enumerator
enum EquipType { WEAPON, CRICKET }
@export var equip_type: EquipType = EquipType.WEAPON

@export var resource_type : Resource


const EQUIP_TYPES = []

var coin_sfx: AudioStream = preload("res://assets/audio/sfx/coin-4.wav")
var key_sfx: AudioStream = preload("res://assets/audio/sfx/collect-5.wav")
var item_equipSFX: AudioStream = preload("res://assets/audio/sfx/Magic Spell 1.wav")
var weapon_equipSFX: AudioStream = preload("res://assets/audio/sfx/Extra Life.wav")


# Called when the node enters the scene tree for the first time.
#Connects the body_entered node of the scene to the function _on_body_entered() function
#This will make it so any pickup item (not passive item) can use this file and class
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

#When the Player runs into the pickup it will see if the Player has a inventory
#If there is a inventory it will call the function add_resource() and add the resource to the inventory
func _on_body_entered(body : Node2D) -> void:
	if not body.is_in_group("Player"):
		return
		
	# Play SFX based on the exported enumerator
	var played : bool = false

	match item_type:
		ItemType.COIN:
			AudioManager.play_sfx(coin_sfx)
			played = true
		ItemType.KEY:
			AudioManager.play_sfx(key_sfx)
			played = true

	if not played:
		match equip_type:
			EquipType.WEAPON:
				AudioManager.play_sfx(weapon_equipSFX)
			EquipType.CRICKET:
				AudioManager.play_sfx(item_equipSFX)
		
	var inventory = body.find_child("Inventory")
	if(inventory):
		inventory.add_resources(resource_type, 1)
		
		queue_free()
		
