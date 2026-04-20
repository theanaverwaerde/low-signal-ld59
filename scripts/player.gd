extends CharacterBody3D

@onready var camera_3d: Camera3D = %Camera3D
@onready var footstep_sound: AudioStreamPlayer = $FootstepSound

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MOUSE_SENSIBILITY = 1000

const STEP_TIME = .35
var current_step_time = 0

var camera_base_height = 0
var camera_max_height = 0

var enable

func _ready() -> void:
	camera_base_height = camera_3d.position.y
	camera_max_height = camera_base_height + .06

func _input(event: InputEvent) -> void:
	if !enable:
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x / MOUSE_SENSIBILITY)
		camera_3d.rotate_x(-event.relative.y / MOUSE_SENSIBILITY)
		camera_3d.rotation.x = clampf(camera_3d.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _process(delta: float) -> void:
	if not enable:
		return
	
	if is_on_floor() and velocity.x != 0 and velocity.z != 0:
			current_step_time -= delta
			if current_step_time <= 0:
				footstep_sound.play()
				current_step_time = STEP_TIME
			
	camera_3d.position.y = lerp(camera_base_height, camera_max_height, current_step_time / STEP_TIME)

func _physics_process(delta: float) -> void:
	if !enable:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		current_step_time = 0

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
		current_step_time = 0

	move_and_slide()


func _on_awake_awake() -> void:
	enable = true
	
func _on_end() -> void:
	enable = false
