class_name Garbage extends Area3D

@export var item: Item
signal picked_up(garbage: Garbage)
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func get_interaction_text() -> String:
	return "Press 'E' to pickup " + item.item_name

func can_interact() -> bool:
	return true
	
func interact(player: Player) -> void:
	if player.inventory.items.size() < player.inventory.MAX_INVENTORY_SIZE:
		player.inventory.add_item(item)
		picked_up.emit(self)
		AudioManager.play_garbage_pickup_sound()
		if not player.has_picked_up:
			player.has_picked_up = true
			player.hud.show_crafting_hint()
		get_parent().queue_free()
	else:
		player.hud.dialogue_box.show_dialogue_box("tumi", ["i can't carry this many items... im smol boi ;-;"])

func disable() -> void:
	collision_shape.disabled = true
	
func enable() -> void:
	collision_shape.disabled = false
