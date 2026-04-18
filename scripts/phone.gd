extends Node3D

@onready var full_size: Node3D = $"../fullPos"
@onready var min_size: Node3D = $"../minPos"
# @onready var helper_text: Label = $HelperText

@onready var signal_label: Label = %SignalLabel
@onready var signal_source: SignalSource = %SignalSource
@onready var player: CharacterBody3D = %Player

@export var switch_curve : Curve
const TIME : float = .2
@onready var phone_screen: SubViewport = %PhoneScreen
const PHONE_SCREEN = preload("uid://dwslou3wpdsev")

var show_phone : bool = false
var current_time : float
var first_touch : bool

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var vp_texture: ViewportTexture = phone_screen.get_texture()
	
	PHONE_SCREEN.set_texture(BaseMaterial3D.TextureParam.TEXTURE_ALBEDO, vp_texture)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if !first_touch && event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		first_touch = true
	
	if event.is_action_pressed("phone"):
#		if helper_text.visible:
#			helper_text.visible = false
		show_phone = !show_phone
		if show_phone:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta: float) -> void:
	process_phone_size(delta)
	process_signal()
	
func process_signal() -> void:
	signal_label.text = "SIGNAL: " + str(signal_source.get_signal(player))

func process_phone_size(delta: float) -> void:
	if current_time != TIME and show_phone:
		current_time = min(TIME,current_time+delta)
	
	if current_time != 0 and !show_phone:
		current_time = max(0,current_time-delta)
	
	var weight = current_time/TIME
	
	global_position = lerp(min_size.global_position, full_size.global_position, weight)
	global_rotation = lerp(min_size.global_rotation, full_size.global_rotation, weight)
	scale = lerp(min_size.scale, full_size.scale, weight)
