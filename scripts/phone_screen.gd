class_name PhoneScreen
extends SubViewport

@onready var signal_source: SignalSource = %SignalSource

@onready var signal_label: Label = $VBoxContainer/SignalLabel
@onready var button: Button = $VBoxContainer/Button
@onready var result: Label = $VBoxContainer/Result

func _ready() -> void:
	signal_source.power_changed.connect(process_signal)
	process_signal(0)

func process_signal(power : int) -> void:
	signal_label.text = "SIGNAL: " + str(power)

func _on_button_pressed() -> void:
	if signal_source.get_signal() == SignalSource.MAX_POWER:
		result.text = "\"We are coming!\""
	else:
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
