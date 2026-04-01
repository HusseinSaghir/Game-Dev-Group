extends Area2D

var oreData: OreData

@onready var sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = oreData.texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.add_ore(oreData):
			queue_free()
