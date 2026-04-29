extends CanvasLayer

@onready var hp_bar
@onready var stamina_bar

@export var player: Node

# Inventory HUD 
var inventory_slots = []
var current_slot := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp_bar = get_node("RootControl/HealthUI/HPBar")
	stamina_bar = get_node("RootControl/HealthUI/StaminaBar")
	
	inventory_slots = [
		get_node("RootControl/Inventory/Slot1/Icon"), 
		get_node("RootControl/Inventory/Slot2/Icon"), 
		get_node("RootControl/Inventory/Slot3/Icon"),
		get_node("RootControl/Inventory/Slot4/Icon")
	]
	
	add_to_group("HUD")
		
	# --- SYNC 
	if player:
		set_health(player.current_health)
		set_stamina(player.current_stamina)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_health(value: float):
	if hp_bar:
		hp_bar.value = value

func on_damage_taken(value: float):
	if not hp_bar:
		return
	print_debug("[HUD] Health bar animating to: ", value)
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", value, 0.3).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(hp_bar, "modulate", Color(1.0, 0.15, 0.15), 0.05)
	tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.25)
	
func set_stamina(value: float):
	if stamina_bar:	
		stamina_bar.value = value
		
func add_item(texture: Texture2D):
	if current_slot >= inventory_slots.size():
		print("Inventory full")
		return 
		
	inventory_slots[current_slot].texture = texture
	current_slot += 1
