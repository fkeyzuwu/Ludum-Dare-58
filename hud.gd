class_name HUD extends Control

@onready var interaction_label: Label = $InteractionLabel
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var inventory_container: HBoxContainer = $Inventory
@export var crafter: Crafter
@onready var thanks_for_playing_label: Label = $ThanksForPlayingLabel
@onready var fade: ColorRect = $Fade
@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var crafting_hint_label: Label = $CraftingHintLabel
@onready var end_game_buttons: HBoxContainer = $EndGameButtons
@onready var camera_joystick: VirtualJoystick = $CameraJoystick
@onready var move_joystick: VirtualJoystick = $MoveJoystick
@onready var touch_buttons: Control = $TouchButtons
@onready var player: Player = get_parent()

func _ready() -> void:
	crafting_hint_label.modulate.a = 0.0
	fade_in()
	touch_buttons.visible = DisplayServer.is_touchscreen_available()

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(fade, ^"color:a", 0.0, 5.0).from(1.0)
	
func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade, ^"color:a", 1.0, 5.0)
	await tween.finished
	show_thanks_for_playing_label()

func show_interaction_text(text: String) -> void:
	interaction_label.text = text

func hide_interaction_text() -> void:
	interaction_label.text = ""

func show_thanks_for_playing_label() -> void:
	thanks_for_playing_label.visible = true
	end_game_buttons.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.end_game = true
	player.footstep_timer.stop()

func show_options() -> void:
	options_menu.show_options()

func hide_options() -> void:
	options_menu.hide_options()

func show_crafting_hint() -> void:
	crafting_hint_label.visible = true
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(crafting_hint_label, ^"modulate:a", 1.0, 3.5).set_delay(3.0)
	
func hide_crafting_hint() -> void:
	crafting_hint_label.visible = false

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_touch_button_pressed() -> void:
	player.handle_options()

func _on_craft_touch_button_pressed() -> void:
	player.handle_crafting()

func _on_jump_touch_button_pressed() -> void:
	if player.can_jump():
		player.jump_buffered = true

func _on_interact_touch_button_pressed() -> void:
	print("touch")
	player.try_interact(true)
