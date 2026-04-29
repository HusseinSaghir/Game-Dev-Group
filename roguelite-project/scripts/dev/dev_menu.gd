extends Node

const PICKUP_KEY    = preload("res://scenes/items/pickups/pickup_key.tscn")
const PICKUP_COIN   = preload("res://scenes/items/pickups/pickup_coin.tscn")
const CHEESE        = preload("res://scenes/items/cheese.tscn")
const DAMAGE_GEM    = preload("res://scenes/items/damage_gem.tscn")
const FEATHER       = preload("res://scenes/items/feather.tscn")
const MEDBREW       = preload("res://scenes/items/medbrew.tscn")
const WEAPON_SWORD  = preload("res://scenes/items/weapon_items/weapon_sword_item.tscn")
const WEAPON_BOW    = preload("res://scenes/items/weapon_items/weapon_shortbow_item.tscn")
const WEAPON_STAFF  = preload("res://scenes/items/weapon_items/weapon_staff_item.tscn")
const WEAPON_PISTOL = preload("res://scenes/items/weapon_items/weapon_pistol_item.tscn")

var dev_mode: bool = false

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	print_debug("[DevMenu] Loaded. Press Z to toggle.")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Z:
				dev_mode = !dev_mode
				print_debug("[DevMenu] Dev mode: ", "ON" if dev_mode else "OFF")
			KEY_K:
				if dev_mode:
					_spawn_at_player(PICKUP_KEY)
					print_debug("[DevMenu] Spawned Key")
			KEY_C:
				if dev_mode:
					_spawn_at_player(PICKUP_COIN)
					print_debug("[DevMenu] Spawned Coin")
			KEY_1:
				if dev_mode:
					_spawn_at_player(CHEESE)
					print_debug("[DevMenu] Spawned Cheese")
			KEY_2:
				if dev_mode:
					_spawn_at_player(DAMAGE_GEM)
					print_debug("[DevMenu] Spawned Damage Gem")
			KEY_3:
				if dev_mode:
					_spawn_at_player(FEATHER)
					print_debug("[DevMenu] Spawned Feather")
			KEY_4:
				if dev_mode:
					_spawn_at_player(MEDBREW)
					print_debug("[DevMenu] Spawned Med Brew")
			KEY_5:
				if dev_mode:
					_spawn_at_player(WEAPON_SWORD)
					print_debug("[DevMenu] Spawned Sword")
			KEY_6:
				if dev_mode:
					_spawn_at_player(WEAPON_BOW)
					print_debug("[DevMenu] Spawned Shortbow")
			KEY_7:
				if dev_mode:
					_spawn_at_player(WEAPON_STAFF)
					print_debug("[DevMenu] Spawned Staff")
			KEY_8:
				if dev_mode:
					_spawn_at_player(WEAPON_PISTOL)
					print_debug("[DevMenu] Spawned Pistol")

func _spawn_at_player(scene: PackedScene) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")
	if not player:
		print_debug("[DevMenu] No player found!")
		return
	var item = scene.instantiate()
	item.global_position = player.global_position + Vector2(20, 0)
	get_tree().current_scene.add_child(item)
