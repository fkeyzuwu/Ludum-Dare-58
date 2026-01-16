class_name GarbageTruck extends AnimatableBody3D

@export var speed: float
@onready var spawn_pos = global_position

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(Vector3.LEFT * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			collider.kill()
			collider.velocity = -collision.get_normal() * speed
			collider.move_and_slide()
		else:
			push_error("WINO WINO PLAYER NOT COLLIDEER SPOTTED IN GARABEG TRUCK")
	
func reset_to_start_position() -> void:
	global_position = spawn_pos

func _on_timer_timeout() -> void:
	reset_to_start_position()
