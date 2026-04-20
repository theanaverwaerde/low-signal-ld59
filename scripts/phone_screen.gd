class_name PhoneScreen
extends SubViewport

@onready var signal_source: SignalSource = %SignalSource

@onready var time_label: Label = $Screen/TimeLabel
@onready var signal_label: Label = $Screen/SignalLabel
@onready var result: Label = $Screen/DefaultScreen/Result

@onready var default_screen: VBoxContainer = $Screen/DefaultScreen
@onready var options_screen: VBoxContainer = $Screen/OptionsScreen

@onready var options: Button = $options

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var click: AudioStreamPlayer3D = $click

var use_12h_format : bool
var show_option : bool

func _ready() -> void:
	signal_source.power_changed.connect(process_signal)
	process_signal(0)

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
	signal_label.text = "SIGNAL: " + str(power) + "/" + str(signal_source.zones.size())

func _on_button_pressed() -> void:
	if signal_source.get_signal() == signal_source.zones.size():
		result.text = "\"We are coming!\""
	else:
		audio_stream_player_3d.play()
		result.text = "No enough signal"
		await wait(.4)
		result.text = "No enough signal."
		await wait(.4)
		result.text = "No enough signal.."
		await wait(.4)
		result.text = "No enough signal..."
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
	click.play()
