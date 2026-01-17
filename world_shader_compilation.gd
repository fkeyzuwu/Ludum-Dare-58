extends Node3D
@onready var item_container: Node3D = $ItemContainer

func _ready() -> void:
	var tween = create_tween().set_parallel()
	for item in item_container.get_children():
		tween.tween_property(item, "rotation_degrees:y", 359.0, 0.5)
	
	await tween.finished
	print("hi")
	if get_parent() is SubViewport:
		get_parent().queue_free()
