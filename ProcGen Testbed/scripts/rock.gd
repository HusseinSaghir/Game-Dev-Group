extends StaticBody2D
class_name Rock

const ORE_SCENE := preload("res://scenes/ore.tscn")
const FLASH_COLOR := Color(2.454, 2.454, 2.454, 1.0)

var health: int

@export var data: RockData

@onready var sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = data.maxHealth
	sprite.texture = data.texture
	
func takeDamage(amount: int) -> void:
	flash()
	health -= amount
	print(health)
	if health <= 0:
		destroyRock()
		
func flash() -> void:
	sprite.modulate = FLASH_COLOR
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
func destroyRock() -> void:
	queue_free()
	dropOre()
	
func dropOre() -> void:
	var ore = ORE_SCENE.instantiate()
	ore.position = position
	ore.oreData = data.oreResource
	
	var random_x = randf_range(-15, 15)
	var target_x = ore.position.x + random_x
	
	var levelRoot = get_parent().get_parent()
	var oreContainer = levelRoot.get_node("OreContainer")
	oreContainer.add_child(ore)
	
	var tween = ore.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ore, "position:y", ore.position.y - 20, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ore, "position:y", ore.position.y, 0.3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.3)

	tween.tween_property(ore, "position:x", target_x, 0.6)\
	.set_ease(Tween.EASE_OUT)
