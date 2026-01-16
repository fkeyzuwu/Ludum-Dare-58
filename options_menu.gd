class_name OptionsMenu extends PanelContainer

@export var mouse_sensitivity_slider: HSlider
@export var music_slider: HSlider
@export var sfx_slider: HSlider

const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

@onready var player: Player = get_tree().current_scene.find_child("Player")
@onready var amplify_master: AudioEffectAmplify = AudioServer.get_bus_effect(MASTER_BUS, 0)
@onready var amplify_music: AudioEffectAmplify = AudioServer.get_bus_effect(MUSIC_BUS, 0)
@onready var amplify_sfx: AudioEffectAmplify = AudioServer.get_bus_effect(SFX_BUS, 0)
@onready var lowpass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(MASTER_BUS, 1)

var lowpass_tween: Tween

func _ready() -> void:
	hide()
	music_slider.set_value_no_signal(amplify_music.volume_linear)
	sfx_slider.set_value_no_signal(amplify_sfx.volume_linear)
	mouse_sensitivity_slider.set_value_no_signal(player.mouse_sensitivity)
	
func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	player.mouse_sensitivity = value

func _on_music_volume_slider_value_changed(value: float) -> void:
	amplify_music.volume_linear = value
	
func _on_sfx_volume_slider_value_changed(value: float) -> void:
	amplify_sfx.volume_linear = value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"options"):
		player.handle_options()

func show_options() -> void:
	if lowpass_tween and lowpass_tween.is_running():
		lowpass_tween.kill()
		
	lowpass_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	lowpass_tween.tween_property(lowpass, ^"cutoff_hz", 2000.0, 0.5)
	show()
	get_tree().paused = true
	
func hide_options() -> void:
	hide()
	
	if lowpass_tween and lowpass_tween.is_running():
		lowpass_tween.kill()
		
	lowpass_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	lowpass_tween.tween_property(lowpass, ^"cutoff_hz", 20500.0, 0.5)
	get_tree().paused = false

func _on_resume_pressed() -> void:
	player.handle_options()

func _on_quit_pressed() -> void:
	get_tree().quit()
