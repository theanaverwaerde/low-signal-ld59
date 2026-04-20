class_name PhoneScreen
extends SubViewport

@onready var signal_source: SignalSource = %SignalSource

@onready var time_label: Label = $Screen/HSplitContainer/TimeLabel
@onready var signal_texture: TextureRect = $Screen/HSplitContainer/SignalTextureRect
@onready var result: Label = $Screen/DefaultScreen/Result

@onready var default_screen: VBoxContainer = $Screen/DefaultScreen
@onready var options_screen: VBoxContainer = $Screen/OptionsScreen

@onready var options: Button = $options

@onready var call_fail_sound: AudioStreamPlayer = $CallFailSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

@onready var animation_player: AnimationPlayer = $Startup/AnimationPlayer

var use_12h_format : bool
var show_option : bool

@onready var wall_paper: TextureRect = $WallPaper

@export var signal_icons : Array[Texture2D]

signal finish

var first_focus = false

func _ready() -> void:
	signal_source.power_changed.connect(process_signal)
	process_signal(0)

func change_focus() -> void:
	if !first_focus:
		animation_player.play("phone_startup")
		first_focus = true
	
	if show_option:
		_on_options_pressed()

func _process(delta: float) -> void:
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var extra = ""
	if use_12h_format:
		hour = time.hour % 12
		if hour == 0:
			hour = 12
		extra = " AM" if time.hour < 12 else " PM"
	time_label.text = ("%02d:%02d%s" % [hour, time.minute, extra])

func process_signal(power : int) -> void:
	signal_texture.texture = signal_icons[power]
	
	# signal_label.text = "SIGNAL: " + str(power) + "/" + str(signal_source.zones.size())

func _on_button_pressed() -> void:
	if signal_source.get_signal() == signal_source.zones.size():
		result.text = "\"We are coming!\""
		finish.emit()
	else:
		call_fail_sound.play()
		result.text = "Not enough signal"
		await wait(.4)
		result.text = "Not enough signal."
		await wait(.4)
		result.text = "Not enough signal.."
		await wait(.4)
		result.text = "Not enough signal..."
		await wait(1)
		result.text = ""

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _on_options_pressed() -> void:
	show_option = !show_option
	default_screen.visible = !show_option
	options_screen.visible = show_option
	options.text = "Back" if show_option else "Options"

func _on_hour_format_toggled(toggled_on: bool) -> void:
	use_12h_format = toggled_on
	
func _click_sound() -> void:
	click_sound.play()

func set_wallpaper(i : int) -> void:
	var atlas = wall_paper.texture as AtlasTexture
	atlas.region.position.x = atlas.region.size.x * i
