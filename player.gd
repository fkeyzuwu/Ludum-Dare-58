class_name Player extends CharacterBody3D

const SPEED = 5.0
@export_range(0.1, 5.0, 0.01) var stop_friction := 5.0
const JUMP_VELOCITY = 3.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_range(0.01, 1.0, 0.01) var mouse_sensitivity := 0.4

@onready var camera: Camera3D = $Camera3D
@export var interaction_raycast: RayCast3D
@export var hud: HUD
@export var inventory: PlayerInventory
@onready var spawn_pos := global_position
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var footstep_timer: Timer = $FootstepTimer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.dialogue_box.opened.connect(_on_dialogue_box_opened)
	hud.dialogue_box.closed.connect(_on_dialogue_box_closed)

enum State {
	Idle,
	Dialogue,
	Crafting,
	Options
}

var state := State.Idle
var is_walking := false
var spawned = false
var has_picked_up = false

func _exit_current_state(new_state: State) -> void:
	match state:
		State.Crafting:
			if new_state != State.Options:
				hud.crafter.return_crafting_slots()
				hud.crafter.hide_crafter()
		State.Options:
			hud.hide_options()

func enter_state(_state: State) -> void:
	_exit_current_state(_state)
	
	match _state:
		State.Idle:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		State.Dialogue:
			hud.hide_interaction_text()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		State.Crafting:
			hud.hide_interaction_text()
			hud.crafter.show_crafter()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		State.Options:
			hud.show_options()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	state = _state

func _on_dialogue_box_opened() -> void:
	enter_state(State.Dialogue)
	
func _on_dialogue_box_closed() -> void:
	enter_state(State.Idle)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and state == State.Idle:
		global_rotation.y -= event.relative.x * mouse_sensitivity * 0.01
		camera.global_rotation.x -= event.relative.y * mouse_sensitivity * 0.01
		camera.global_rotation_degrees.x = clampf(camera.global_rotation_degrees.x, -80.0, 80.0)
	elif event.is_action_pressed(&"craft"):
		if state == State.Idle:
			enter_state(State.Crafting)
		elif state == State.Crafting:
			enter_state(State.Idle)
	elif event.is_action_pressed(&"change_mouse_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func handle_options() -> void:
	if state == State.Options:
		if hud.crafter.visible:
			enter_state(State.Crafting)
		else:
			enter_state(State.Idle)
	else:
		enter_state(State.Options)

func _physics_process(delta: float) -> void:
	move(delta)
	try_interact()

func move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and state == State.Idle:
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and state == State.Idle:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, stop_friction)
		velocity.z = move_toward(velocity.z, 0, stop_friction)
	
	if not is_walking and velocity.length() >= 0.1:
		if spawned:
			is_walking = true
			AudioManager.footstep_player.play()
			footstep_timer.start()
		else:
			spawned = true
		
	elif is_walking and velocity.length() <= 0.1:
		is_walking = false
		footstep_timer.stop()
	
	move_and_slide()

func try_interact() -> void:
	match state:
		State.Idle:
			if interaction_raycast.is_colliding():
				var interactable = interaction_raycast.get_collider()
				if not interactable:
					hud.hide_interaction_text()
				else:
					if interactable.can_interact():
						if Input.is_action_just_pressed(&"interact"):
							await interactable.interact(self)
						else:
							hud.show_interaction_text(interactable.get_interaction_text())
					else:
						hud.hide_interaction_text()
			else:
				hud.hide_interaction_text()
		State.Dialogue:
			if Input.is_action_just_pressed(&"interact") or Input.is_action_just_pressed(&"mouse_left"):
				hud.dialogue_box.continue_dialogue()

func kill() -> void:
	global_position = spawn_pos
	animation_player.play(&"respawn")
	move_and_slide()

func _on_footstep_timer_timeout() -> void:
	AudioManager.footstep_player.play()

func _on_death_boundary_body_entered(body: Node3D) -> void:
	if body is Player:
		kill()
