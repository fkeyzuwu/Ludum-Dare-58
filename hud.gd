class_name HUD extends Control

@onready var interaction_label: Label = $InteractionLabel
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var inventory_container: HBoxContainer = $Inventory
@export var crafter: Crafter
@onready var thanks_for_playing_label: Label = $ThanksForPlayingLabel
@onready var fade: ColorRect = $Fade
@onready var options_menu: OptionsMenu = $OptionsMenu

func _ready() -> void:
	fade_in()

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

func show_options() -> void:
	options_menu.show_options()

func hide_options() -> void:
	options_menu.hide_options()
