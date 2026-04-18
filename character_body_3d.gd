extends CharacterBody3D

@onready var signal_label: Label = %SignalLabel
@onready var camera_3d: Camera3D = %Camera3D
@onready var signal_source: Node3D = %SignalSource

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MOUSE_SENSIBILITY = 1000

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE && !show_phone:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x / MOUSE_SENSIBILITY)
		camera_3d.rotate_x(-event.relative.y / MOUSE_SENSIBILITY)
		camera_3d.rotation.x = clampf(camera_3d.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _process(delta: float) -> void:
	var pos2d = Vector2(position.x, position.z)
	var signal_pos2d = Vector2(signal_source.position.x, signal_source.position.z)
	var power : int = ceil(pos2d.distance_to(signal_pos2d))
	power = max(0, min(51-power, 50))
	signal_label.text = "SIGNAL: " + str(power)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
